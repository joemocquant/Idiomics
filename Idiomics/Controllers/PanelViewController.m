//
//  PanelViewController.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/11/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "PanelViewController.h"
#import "Colors.h"
#import "Panel.h"
#import "Balloon.h"
#import "BalloonsOverlay.h"
#import "PanelImageStore.h"
#import "NavigationView.h"
#import "MMSViewController.h"
#import <UIView+AutoLayout.h>
#import <GAI.h>
#import <GAIDictionaryBuilder.h>

@interface PanelViewController ()

@property (nonatomic, readwrite, strong) UIView *inputAccessoryView;

@end

@implementation PanelViewController


#pragma mark - Lifecycle

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (instancetype)initWithPanel:(Panel *)p
{
    self = [super init];
    
    if (self) {
        panel = p;
        panelId = panel.panelId;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        CGRect screen = [[UIScreen mainScreen] bounds];
        
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            //[self.view setFrame:CGRectMake(0, 0, CGRectGetWidth(screen), CGRectGetHeight(screen))];
        } else {
            [self.view setFrame:CGRectMake(0, 0, CGRectGetHeight(screen), CGRectGetWidth(screen))];
        }
    }
    
    [self.view setBackgroundColor:[panel.averageColor colorWithAlphaComponent:AlphaBackground]];
    
    panelScrollView = [UIScrollView new];
    [panelScrollView setDelegate:self];
    [panelScrollView setShowsHorizontalScrollIndicator:NO];
    [panelScrollView setShowsVerticalScrollIndicator:NO];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(panelScrollViewTappedTwice:)];
    [doubleTap setNumberOfTapsRequired:2];
    [doubleTap setNumberOfTouchesRequired:1];
    
    [panelScrollView addGestureRecognizer:doubleTap];
    [panelScrollView setUserInteractionEnabled:YES];
    
    [self panelScrollViewSetFrameBeforeRotation:NO];
    
    [self.view addSubview:panelScrollView];
    
    UIImage *image = [[[PanelImageStore sharedStore] panelFullSizeImageForKey:panel.imageUrl] copy];

    //image size is in pixels! converting to points
    CGSize imageSize = CGSizeMake(image.size.width / [[UIScreen mainScreen] scale],
                                  image.size.height / [[UIScreen mainScreen] scale]);
    
    panelView = [UIView new];
    [panelView setBackgroundColor:[Colors clear]];
    
    CGSize contentSize = CGSizeMake(imageSize.width + 2 * Gutter, imageSize.height + 2 * Gutter);
    [panelView setFrame:CGRectMake(0, 0, contentSize.width, contentSize.height)];
    [panelView setCenter:panelScrollView.center];
    
    [[panelView layer] setShadowColor:[[Colors white] CGColor]];
    [[panelView layer] setShadowOpacity:1.0];
    [[panelView layer] setShadowOffset:CGSizeZero];
    [[panelView layer] setShadowRadius:0.8];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(-2,
                                                                           -2,
                                                                           contentSize.width + 2 + 2,
                                                                           contentSize.height + 2 + 2)];
    [[panelView layer] setShadowPath:[shadowPath CGPath]];
    
    [panelScrollView setContentSize:contentSize];
    [panelScrollView addSubview:panelView];
    
    panelImageView = [[UIImageView alloc] initWithImage:image];
    [panelImageView setContentScaleFactor:2];
    [panelImageView setFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    [panelImageView setCenter:CGPointMake(contentSize.width / 2, contentSize.height / 2)];
    [panelView addSubview:panelImageView];
    
    balloonsOverlay = [[BalloonsOverlay alloc] initWithPanel:panel];
    [balloonsOverlay setFrame:panelImageView.frame];
    [panelView addSubview:balloonsOverlay];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:balloonsOverlay
                                                                                action:@selector(balloonsOverlayTappedOnce:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [panelScrollView addGestureRecognizer:singleTap];
    
    [self setupNavigationView];
    [self updateScalesWithContentSize:panelScrollView.contentSize];
    
    [panelScrollView setZoomScale:screenScale * ScaleFactor animated:YES];
}

- (void)setupNavigationView
{
    NavigationView *navigationView = [NavigationView new];
    
    [[navigationView cancel] addTarget:self action:@selector(back)
                      forControlEvents:UIControlEventTouchUpInside];
    [[navigationView send] addTarget:self action:@selector(sendMessage)
                    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:navigationView];
    [self setInputAccessoryView:navigationView];
    [balloonsOverlay setNavigationView:navigationView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Gestures

- (void)panelScrollViewTappedTwice:(UIGestureRecognizer *)gestureRecognizer
{
    [UIView animateWithDuration:ZoomDuration animations:^{
        if ([panelScrollView zoomScale] < screenScale) {
            [panelScrollView setZoomScale:screenScale animated:YES];
        } else if ([panelScrollView zoomScale] == screenScale) {
                [panelScrollView setZoomScale:screenScale * ZoomScaleFactor animated:YES];
            } else {
                [panelScrollView setZoomScale:panelScrollView.minimumZoomScale animated:YES];
            }
    }];
}


#pragma mark - Keyboard notification

- (void)keyboardWillHide:(NSNotification *)notification
{
    keyboardOffset = 0.0;
    [self resizeScrollView];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];

    CGFloat keyboardHeight;
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            keyboardHeight = keyboardBounds.size.height;
        } else {
            keyboardHeight = keyboardBounds.size.width;
        }
        
    } else {
        keyboardHeight = keyboardBounds.size.height;
    }

    if (keyboardHeight > NavigationControlHeight) {
        
        keyboardOffset = keyboardHeight;
        [self resizeScrollView];
    }
}


#pragma mark - Rotation iPad

//iOS 7.x
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                               duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self centerScrollViewContentsBeforeRotation:YES];
    
    [panelScrollView setContentSize:CGSizeMake(panelImageView.frame.size.width + 2 * Gutter,
                                               panelImageView.frame.size.height + 2 * Gutter)];
    
    [self updateScalesWithContentSize:panelScrollView.contentSize];
    
    if (panelScrollView.zoomScale < panelScrollView.minimumZoomScale) {
        //[panelScrollView setZoomScale:panelScrollView.minimumZoomScale animated:YES]; //screen bug
    } else {
        [panelScrollView setZoomScale:panelScrollView.zoomScale animated:YES];
    }
}

//iOS 8.x
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {

        [self centerScrollViewContentsBeforeRotation:YES];
        
        [panelScrollView setContentSize:CGSizeMake(panelImageView.frame.size.width + 2 * Gutter,
                                                   panelImageView.frame.size.height + 2 * Gutter)];
        
        [self updateScalesWithContentSize:panelScrollView.contentSize];
        
        if (panelScrollView.zoomScale < panelScrollView.minimumZoomScale) {
            [panelScrollView setZoomScale:panelScrollView.minimumZoomScale animated:YES];
        } else {
            [panelScrollView setZoomScale:panelScrollView.zoomScale animated:YES];
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
    [self centerScrollViewContentsBeforeRotation:NO];
}

- (void)panelScrollViewSetFrameBeforeRotation:(BOOL)beforeRotation
{
    CGRect screen = [[UIScreen mainScreen] bounds];
    
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            screenWidth = CGRectGetWidth(screen);
            screenHeight = CGRectGetHeight(screen);
        } else {
            screenWidth = CGRectGetHeight(screen);
            screenHeight = CGRectGetWidth(screen);
        }
        
        if (beforeRotation) {
            CGFloat temp = screenHeight;
            screenHeight = screenWidth;
            screenWidth = temp;
        }
    } else {
        screenWidth = CGRectGetWidth(screen);
        screenHeight = CGRectGetHeight(screen);
    }
    
    if (keyboardOffset) {
        [panelScrollView setFrame:CGRectMake(0,
                                             0,
                                             screenWidth,
                                             screenHeight - keyboardOffset + NavigationControlHeight)];
    } else {
        [panelScrollView setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    }
}

- (void)centerScrollViewContentsBeforeRotation:(BOOL)beforeRotation
{
    [self panelScrollViewSetFrameBeforeRotation:beforeRotation];
    
    CGSize frameSize = panelScrollView.frame.size;
    CGRect contentsFrame = panelView.frame;
    
    if (contentsFrame.size.width < frameSize.width) {
        contentsFrame.origin.x = (frameSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < frameSize.height) {
        contentsFrame.origin.y = (frameSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    panelView.frame = contentsFrame;
}


#pragma mark - Private methods

- (void)resizeScrollView
{
    [UIView animateWithDuration:KeyboardMoveDuration animations:^{
        
        [self centerScrollViewContentsBeforeRotation:NO];
        CGSize size = CGSizeMake(panelImageView.frame.size.width + 2 * Gutter,
                                 panelImageView.frame.size.height + 2 * Gutter);
        [self updateScalesWithContentSize:size];
        
        if (keyboardOffset) {
            
            if ([panelScrollView zoomScale] < screenScale) {
                [panelScrollView setZoomScale:screenScale animated:YES];
            } else {
                [panelScrollView setZoomScale:panelScrollView.zoomScale animated:YES];
            }
            
        }
    } completion:^(BOOL finished) {
        if (keyboardOffset) {
            [UIView animateWithDuration:ScrollToBottomDuration animations:^{
                [self focusOnBalloon];
            }];
        }
    }];
}

- (void)focusOnBalloon
{
    CGRect balloon = [panel.balloons[balloonsOverlay.focus] boundsRect];
    CGRect balloonInView = [self.view convertRect:balloon fromView:panelImageView];
    
    CGFloat y = balloonInView.origin.y + balloonInView.size.height;
    
    if (y > (panelScrollView.frame.size.height)) {
        
        CGFloat offsetY = y - panelScrollView.frame.size.height;
        offsetY = offsetY + FocusMoveMargin;
        offsetY = MIN(offsetY, panelScrollView.contentSize.height - panelScrollView.frame.size.height);
        
        CGPoint bottomOffset = CGPointMake(panelScrollView.contentOffset.x,
                                           panelScrollView.contentOffset.y + offsetY);
        [panelScrollView setContentOffset:bottomOffset animated:NO];
    }
    
    if (panelScrollView.zoomScale < 0.5) {
        [panelScrollView zoomToRect:balloon animated:YES];
    }
}

-(void)updateScalesWithContentSize:(CGSize)contentSize
{
    // Set up the minimum & maximum zoom scales

    CGFloat minScale;
    CGRect scrollViewFrame = panelScrollView.frame;
    
    CGFloat scaleWidth = scrollViewFrame.size.width / contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / contentSize.height;

    screenScale = MIN(scaleWidth, scaleHeight);
    
    if (screenScale >= 1) {
        //panel smaller than scrollview
        
        minScale = 1.0;
        if (minScale < (screenScale * ScaleFactor)) {
            minScale = screenScale * ScaleFactor;
        }
        
    } else {
        //panel bigger than scrollview
        minScale = screenScale * ScaleFactor;
    }
    
    [panelScrollView setMinimumZoomScale:minScale];
    [panelScrollView setMaximumZoomScale:minScale * MaxZoomScaleFactor];
}

- (void)back
{
    if (balloonsOverlay.focus != -1) {
        keyboardOffset = 0.0;
        [self resizeScrollView];

        [balloonsOverlay updateVisibilityWithNewFocus:-1];
        
    } else {

        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"panel_edition_cancel"
                                                               label:panelId
                                                               value:nil] build]];
        
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            [_inputAccessoryView removeFromSuperview]; //avoid a segfault
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)sendMessage
{
    if (balloonsOverlay.focus != -1) {
        
        keyboardOffset = 0.0;
        [self resizeScrollView];
        
        [balloonsOverlay updateVisibilityWithNewFocus:-1];
    }
    
    CGSize imageSize = CGSizeMake(panelImageView.image.size.width / [[UIScreen mainScreen] scale] + 2 * Gutter,
                                  panelImageView.image.size.height / [[UIScreen mainScreen] scale] + 2 * Gutter);
    
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
    
    [panelView drawViewHierarchyInRect:panelImageView.frame afterScreenUpdates:YES];
    
    UIImage *editedPanel = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    MMSViewController *mmsvc = [[MMSViewController alloc] initWithEditedPanel:editedPanel panelId:panelId];
    
    if ([mmsvc canSendPanel]) {
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            [self resignFirstResponder];
        }
        
        [self presentViewController:mmsvc animated:YES completion:nil];
    }
}

- (void)messageSentAnimation
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"message_send_success"
                                                           label:panelId
                                                           value:@([balloonsOverlay charactersCount])] build]];
    
    [UIView animateWithDuration:TransitionDuration * 2 animations:^{
        [panelView setAlpha:0];
        [panelView setCenter:CGPointMake(self.view.center.x, -panelView.center.y)];
        
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

@end
