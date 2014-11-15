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
#import "PanelImageStore.h"
#import "MMSViewController.h"
#import <UIView+AutoLayout.h>

@interface PanelViewController ()

@property (nonatomic, readwrite, retain) UIView *inputAccessoryView;

@end

@implementation PanelViewController

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (UIView *)inputAccessoryView
{
    if (!_inputAccessoryView) {
        MessageBar *messageBar = [MessageBar new];
        [messageBar setDelegate:self];
        
        _inputAccessoryView = messageBar;
    }
    
    return _inputAccessoryView;
}


#pragma mark - Initialization

- (instancetype)initWithPanel:(Panel *)p
{
    self = [super init];
    
    if (self) {
        panel = p;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    panelScrollView = [UIScrollView new];
    [panelScrollView setDelegate:self];
    [panelScrollView setBackgroundColor:[[Colors gray3] colorWithAlphaComponent:0.8f]];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(PanelScrollViewTapped:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    
    [panelScrollView addGestureRecognizer:singleTap];
    [panelScrollView setUserInteractionEnabled:YES];
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    [panelScrollView setFrame:CGRectMake(0, 0, CGRectGetWidth(screen), CGRectGetHeight(screen) - MessageBarHeight)];
    [self.view addSubview:panelScrollView];
    
    panelImageView = [UIImageView new];
    [panelImageView setImage:[((UIImage *)[[PanelImageStore sharedStore] panelImageForKey:panel.imageUrl]) copy]];
    [panelImageView setFrame:CGRectMake(0, 0, panelImageView.image.size.width, panelImageView.image.size.height)];
    [panelImageView setCenter:panelScrollView.center];
    [panelScrollView setContentSize:panelImageView.image.size];
    [panelScrollView addSubview:panelImageView];

    [self setupSpeechBalloons];
    [self setupScales];
}

-(void)setupScales {
    // Set up the minimum & maximum zoom scales
    
    CGFloat minScale;
    CGRect scrollViewFrame = panelScrollView.frame;
    
    CGFloat scaleWidth = scrollViewFrame.size.width / panelScrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / panelScrollView.contentSize.height;
    CGFloat screenScale = MIN(scaleWidth, scaleHeight);
    
    if (screenScale >= 1) {
        //panel smaller than scrollview
        minScale = 1.0;
    } else {
        //panel bigger than scrollview
        minScale = screenScale;
    }
    
    [panelScrollView setMinimumZoomScale:minScale];
    [panelScrollView setMaximumZoomScale:minScale * 4.0];
    [panelScrollView setZoomScale:minScale];
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
        [speechBalloons addObject:ballonLabel];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)PanelScrollViewTapped:(UIGestureRecognizer *)gestureRecognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         [self centerScrollViewContents];
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {

     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return panelImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents
{
    CGRect screen = [[UIScreen mainScreen] bounds];
    
    [panelScrollView setFrame:CGRectMake(0, 0, CGRectGetWidth(screen), CGRectGetHeight(screen) - MessageBarHeight)];
    CGSize boundsSize = panelScrollView.frame.size;
    
    CGRect contentsFrame = panelImageView.frame;
    
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
    
    panelImageView.frame = contentsFrame;
}

#pragma mark - MessageBarDelegate

- (void)didPressNext
{
    UIImage *imagePanel = [[PanelImageStore sharedStore] panelImageForKey:panel.imageUrl];
    
    MMSViewController *mmsvc = [[MMSViewController alloc] initWithEditedPanel:imagePanel];

    [mmsvc setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    [self presentViewController:mmsvc animated:YES completion:nil];
}

- (void)messageDidChange:(NSString *)text
{
    UILabel *currentBallon = speechBalloons[0];
    currentBallon.font = [Fonts laffayetteComicPro14];
    [currentBallon setText:text];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    textView.text = @"";
    return YES;
}

@end
