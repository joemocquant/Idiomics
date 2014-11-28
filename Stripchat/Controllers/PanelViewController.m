//
//  PanelViewController.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/11/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "PanelViewController.h"
#import "MessageBar.h"
#import "Colors.h"
#import "Fonts.h"
#import "Panel.h"
#import "PanelImageStore.h"
#import "MMSViewController.h"
#import <UIView+AutoLayout.h>

@implementation PanelViewController


#pragma mark - Initialization

- (instancetype)initWithPanel:(Panel *)p
{
    self = [super init];
    
    if (self) {
        panel = p;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    panelScrollView = [UIScrollView new];
    [panelScrollView setDelegate:self];
    [panelScrollView setBackgroundColor:[panel.averageColor colorWithAlphaComponent:AlphaBackground]];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(PanelScrollViewTappedOnce:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    
    [panelScrollView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(PanelScrollViewTappedTwice:)];
    [doubleTap setNumberOfTapsRequired:2];
    [doubleTap setNumberOfTouchesRequired:1];
    
    [panelScrollView addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [panelScrollView setUserInteractionEnabled:YES];
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    [panelScrollView setFrame:CGRectMake(0, 0, CGRectGetWidth(screen), CGRectGetHeight(screen))];
    [self.view addSubview:panelScrollView];
    
    UIImage *image = [[[PanelImageStore sharedStore] panelFullSizeImageForKey:panel.imageUrl] copy];

    //image size is in pixels! converting to points
    CGSize imageSize = CGSizeMake(image.size.width / [[UIScreen mainScreen] scale],
                                  image.size.height / [[UIScreen mainScreen] scale]);
    
    panelView = [UIView new];
    [panelView setBackgroundColor:[Colors white]];
    [panelView setFrame:CGRectMake(0, 0, imageSize.width + Gutter, imageSize.height + Gutter)];
    [panelView setCenter:panelScrollView.center];

    [[panelView layer] setShadowColor:[[Colors white] CGColor]];
    [[panelView layer] setShadowOpacity:1.0];
    [[panelView layer] setShadowOffset:CGSizeZero];
    [[panelView layer] setShadowRadius:0.8];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(-2,
                                                                           -2,
                                                                           imageSize.width + Gutter + 2 + 2,
                                                                           imageSize.height + Gutter + 2 + 2)];
    [[panelView layer] setShadowPath:[shadowPath CGPath]];
    
    
    [panelScrollView setContentSize:panelView.frame.size];
    [panelScrollView addSubview:panelView];
    
    panelImageView = [[UIImageView alloc] initWithImage:image];
    [panelImageView setContentScaleFactor:2];
    [panelImageView setFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    [panelImageView setContentMode:UIViewContentModeCenter];
    [panelImageView setCenter:CGPointMake((imageSize.width + Gutter) / 2, (imageSize.height + Gutter) / 2)];
    [panelView addSubview:panelImageView];

    [self setupSpeechBalloons];
    [self setupScales];
    [panelScrollView setZoomScale:screenScale * ScaleFactor];
}

-(void)setupScales
{
    // Set up the minimum & maximum zoom scales
    
    CGRect scrollViewFrame = panelScrollView.frame;
    
    CGFloat scaleWidth = scrollViewFrame.size.width / panelScrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / panelScrollView.contentSize.height;
    screenScale = MIN(scaleWidth, scaleHeight);
    
    if (screenScale >= 1) {
        //panel smaller than scrollview
        
        minScale = 1.0;
        if (minScale < (screenScale * ScaleFactor)) {
            minScale = screenScale * ScaleFactor;
        }
        
    } else {
        //panel bigger than scrollview
        minScale = screenScale * 0.85;
    }
    
    [panelScrollView setMinimumZoomScale:minScale];
    [panelScrollView setMaximumZoomScale:minScale * MaxZoomScaleFactor];
}

- (void)setupSpeechBalloons
{
    speechBalloons = [NSMutableArray array];
    for (NSValue *ballon in panel.balloons) {
        CGRect ballonRect = [ballon CGRectValue];
    
        UILabel *ballonLabel = [[UILabel alloc] init];
        [panelImageView addSubview:ballonLabel];
        
        [ballonLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [ballonLabel constrainToSize:ballonRect.size];
        
        [ballonLabel pinEdges:JRTViewPinLeftEdge toSameEdgesOfView:panelImageView inset:ballonRect.origin.x];
        [ballonLabel pinEdges:JRTViewPinTopEdge toSameEdgesOfView:panelImageView inset:ballonRect.origin.y];
        
        [ballonLabel setNumberOfLines:0];
        [ballonLabel setAdjustsFontSizeToFitWidth:YES];
        [ballonLabel setTextAlignment:NSTextAlignmentCenter];
        [ballonLabel setFont:[Fonts laffayetteComicPro14]];
        [ballonLabel setTextColor:[Colors gray5]];
        [speechBalloons addObject:ballonLabel];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Gestures

- (void)PanelScrollViewTappedOnce:(UIGestureRecognizer *)gestureRecognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)PanelScrollViewTappedTwice:(UIGestureRecognizer *)gestureRecognizer
{
    [UIView animateWithDuration:ZoomDuration animations:^{
        if ([panelScrollView zoomScale] < screenScale) {
            [panelScrollView setZoomScale:screenScale];
        } else if ([panelScrollView zoomScale] == screenScale) {
                [panelScrollView setZoomScale:screenScale * ZoomScaleFactor];
            } else {
                [panelScrollView setZoomScale:minScale];
            }
        }];
}


#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        panelScrollView.contentSize = panelImageView.image.size;
        [self centerScrollViewContents];
        [self setupScales];
        
        if (panelScrollView.zoomScale < minScale) {
            [panelScrollView setZoomScale:minScale];
        } else {
            [panelScrollView setZoomScale:panelScrollView.zoomScale];
        }
        
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
         
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return panelView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents
{
    CGRect screen = [[UIScreen mainScreen] bounds];
    
    [panelScrollView setFrame:CGRectMake(0, 0, CGRectGetWidth(screen), CGRectGetHeight(screen))];
    CGSize boundsSize = panelScrollView.frame.size;
    
    CGRect contentsFrame = panelView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    panelView.frame = contentsFrame;
}


#pragma mark - MessageBarDelegate

- (void)didPressNext
{
    CGSize imageSize = CGSizeMake(panelImageView.image.size.width / [[UIScreen mainScreen] scale],
                                  panelImageView.image.size.height / [[UIScreen mainScreen] scale]);
    
    CGFloat ratio;
    CGSize newSize;
    CGFloat finalRatio = 4/3;
    
    if (imageSize.width <= imageSize.height) {
        
        ratio = imageSize.height / imageSize.width;
        
        if (ratio >= finalRatio) { //add vertical band
            newSize = CGSizeMake(imageSize.width * ratio / finalRatio, imageSize.height);
        } else { //add horizontal band
            newSize = CGSizeMake(imageSize.width, imageSize.height * finalRatio / ratio);
        }
        
    } else {
        ratio = imageSize.width / imageSize.height;
        
        if (ratio >= finalRatio) { //add horizontal band
            newSize = CGSizeMake(imageSize.width, imageSize.height * ratio / finalRatio);
        } else { //add vertical band
            newSize = CGSizeMake(imageSize.width * finalRatio / ratio, imageSize.height);
        }
    }
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, (newSize.width - imageSize.width) / 2, (newSize.height - imageSize.height) / 2);
    
    [panelImageView drawViewHierarchyInRect:panelImageView.bounds afterScreenUpdates:YES];
    
    UIImage *editedPanel = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    

    MMSViewController *mmsvc = [[MMSViewController alloc] initWithEditedPanel:editedPanel];
    
    if ([mmsvc canSendPanel]) {
        
        [mmsvc setModalTransitionStyle:UIModalTransitionStylePartialCurl];
        [self presentViewController:mmsvc animated:YES completion:nil];
    }
}

- (void)messageDidChange:(NSString *)text
{
    UILabel *currentBallon = speechBalloons[0];
    [currentBallon setText:text];
}

@end
