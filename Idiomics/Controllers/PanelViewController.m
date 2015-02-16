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
#import "NavigationView.h"
#import "DAKeyboardControl.h"
#import "MMSViewController.h"
#import "ShareViewController.h"
#import "UIImage+Tools.h"
#import "Helper.h"
#import <extobjc.h>
#import <UIView+AutoLayout.h>
#import <GAI.h>
#import <GAIDictionaryBuilder.h>

@implementation PanelViewController


#pragma mark - Lifecycle

- (instancetype)initWithPanel:(Panel *)p
{
    self = [super init];
    
    if (self) {
        panel = p;
        itemId = panel.panelId;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        CGRect screen = [UIScreen mainScreen].bounds;
        
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            //self.view.frame = CGRectMake(0, 0, CGRectGetWidth(screen), CGRectGetHeight(screen));
        } else {
            self.view.frame = CGRectMake(0, 0, CGRectGetHeight(screen), CGRectGetWidth(screen));
        }
    }
    
    self.view.backgroundColor = [panel.averageColor colorWithAlphaComponent:AlphaBackground];
    
    panelScrollView = [UIScrollView new];
    panelScrollView.delegate = self;
    panelScrollView.showsHorizontalScrollIndicator = NO;
    panelScrollView.showsVerticalScrollIndicator = NO;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(panelScrollViewTappedTwice:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    
    [panelScrollView addGestureRecognizer:doubleTap];
    panelScrollView.userInteractionEnabled = YES;
    
    [self panelScrollViewSetFrameBeforeRotation:NO];
    
    [self.view addSubview:panelScrollView];
    
    UIImage *image = [panel fullSizeImage];

    panelView = [UIView new];
    panelView.backgroundColor = [Colors clear];
    
    CGSize contentSize = CGSizeMake(image.size.width + 2 * Gutter, image.size.height + 2 * Gutter);
    panelView.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    panelView.center = panelScrollView.center;
    
    panelView.layer.shadowColor = [Colors white].CGColor;
    panelView.layer.shadowOpacity = GutterOpacity;
    panelView.layer.shadowOffset = CGSizeZero;
    panelView.layer.shadowRadius = GutterRadius;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(-GutterShadowOffset,
                                                                           -GutterShadowOffset,
                                                                           contentSize.width + 2 * GutterShadowOffset,
                                                                           contentSize.height + 2 * GutterShadowOffset)];
    panelView.layer.shadowPath = shadowPath.CGPath;
    
    panelScrollView.contentSize = contentSize;
    [panelScrollView addSubview:panelView];
    
    panelImageView = [[UIImageView alloc] initWithImage:image];
    panelImageView.contentScaleFactor = 2;
    panelImageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    panelImageView.center = CGPointMake(contentSize.width / 2, contentSize.height / 2);
    [panelView addSubview:panelImageView];
    
    balloonsOverlay = [[BalloonsOverlay alloc] initWithPanel:panel];
    balloonsOverlay.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [panelImageView addSubview:balloonsOverlay];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:balloonsOverlay
                                                                                action:@selector(balloonsOverlayTappedOnce:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [panelScrollView addGestureRecognizer:singleTap];
 
    share = [UIButton buttonWithType:UIButtonTypeCustom];
    [share setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
    [share addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:share];
    
    [self setupNavigationView];
    [self updateScalesWithContentSize:panelScrollView.contentSize];
    
    [panelScrollView setZoomScale:screenScale * ScaleFactor animated:YES];
}

- (void)setupNavigationView
{
    share.translatesAutoresizingMaskIntoConstraints = NO;
    [share constrainToSize:CGSizeMake(NavigationControlHeight, NavigationControlHeight)];
    [share pinEdges:JRTViewPinRightEdge | JRTViewPinTopEdge toSameEdgesOfView:self.view];
    
    NavigationView *navigationView = [NavigationView new];
    navigationView.share = share;
    
    [navigationView.cancel addTarget:self action:@selector(back)
                    forControlEvents:UIControlEventTouchUpInside];
    [navigationView.send addTarget:self action:@selector(sendMessage)
                  forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:navigationView];
    navigationView.translatesAutoresizingMaskIntoConstraints = NO;
    [navigationView pinEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge toSameEdgesOfView:self.view];
    navigationViewConstraint = [navigationView pinAttribute:NSLayoutAttributeBottom
                                                toAttribute:NSLayoutAttributeBottom
                                                     ofItem:self.view];
    
    [navigationView constrainToHeight:NavigationControlHeight];
    
    balloonsOverlay.navigationView = navigationView;

    @weakify(self)
    [self.view addKeyboardPanningWithFrameBasedActionHandler:nil
                                constraintBasedActionHandler:^(CGRect keyboardFrameInView,
                                                               BOOL opening,
                                                               BOOL closing) {

        @strongify(self)
        CGRect screen = [UIScreen mainScreen].bounds;
                                    
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
                                        
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                self->keyboardOffset = CGRectGetHeight(screen) - keyboardFrameInView.origin.y;
            } else {
                self->keyboardOffset = CGRectGetWidth(screen) - keyboardFrameInView.origin.y;
            }
        } else {
            self->keyboardOffset = CGRectGetHeight(screen) - keyboardFrameInView.origin.y;
        }
                                    
        self->navigationViewConstraint.constant = -self->keyboardOffset;
                                    
        [self resizeScrollView];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
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
        if (panelScrollView.zoomScale < screenScale) {
            [panelScrollView setZoomScale:screenScale animated:YES];
        } else if (panelScrollView.zoomScale == screenScale) {
                [panelScrollView setZoomScale:screenScale * ZoomScaleFactor animated:YES];
            } else {
                [panelScrollView setZoomScale:panelScrollView.minimumZoomScale animated:YES];
            }
    }];
}


#pragma mark - Keyboard notification

- (void)keyboardWillHide:(NSNotification *)notification
{
    keyboardIsPoppingUp = NO;
    keyboardOffset = 0.0;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    keyboardIsPoppingUp = YES;
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];

    CGFloat keyboardHeight;
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            keyboardHeight = CGRectGetHeight(keyboardBounds);
        } else {
            keyboardHeight = CGRectGetWidth(keyboardBounds);
        }

    } else {
        keyboardHeight = CGRectGetHeight(keyboardBounds);
    }

    keyboardOffset = keyboardHeight;
    [self resizeScrollView];
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
        
        panelScrollView.contentSize = CGSizeMake(panelImageView.frame.size.width + 2 * Gutter,
                                                 panelImageView.frame.size.height + 2 * Gutter);
        
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
    CGRect screen = [UIScreen mainScreen].bounds;
    
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
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
        panelScrollView.frame = CGRectMake(0,
                                           0,
                                           screenWidth,
                                           screenHeight - keyboardOffset);
    } else {
        panelScrollView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
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

        if (keyboardIsPoppingUp) {

            if (panelScrollView.zoomScale < screenScale) {
                [panelScrollView setZoomScale:screenScale animated:YES];
            } else {
                [panelScrollView setZoomScale:panelScrollView.zoomScale animated:YES];
            }

        }
    } completion:^(BOOL finished) {
        if (keyboardIsPoppingUp) {
            
            [UIView animateWithDuration:ScrollToBottomDuration animations:^{

                [self focusOnBalloon];
                keyboardIsPoppingUp = NO;
            }];
        }
    }];
}

- (void)focusOnBalloon
{
    CGRect balloon = ((Balloon *)panel.balloons[balloonsOverlay.focus]).boundsRect;
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

- (void)updateScalesWithContentSize:(CGSize)contentSize
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
    
    panelScrollView.minimumZoomScale = minScale;
    panelScrollView.maximumZoomScale = minScale * MaxZoomScaleFactor;
}

- (void)back
{
    if (balloonsOverlay.focus != -1) {
        keyboardOffset = 0.0;
        [self resizeScrollView];

        [balloonsOverlay updateVisibilityWithNewFocus:-1];
        
    } else {

        id tracker = [GAI sharedInstance].defaultTracker;
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"panel_edition_cancel"
                                                               label:panel.panelId
                                                               value:nil] build]];
        
        [self.view removeKeyboardControl];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (UIImage *)preparePanel
{
    if (balloonsOverlay.focus != -1) {
        
        keyboardOffset = 0.0;
        [self resizeScrollView];
        
        [balloonsOverlay updateVisibilityWithNewFocus:-1];
    }
    
    UIGraphicsBeginImageContextWithOptions(panelImageView.image.size, NO, 0);
    [panelImageView drawViewHierarchyInRect:CGRectMake(0,
                                                       0,
                                                       panelImageView.image.size.width,
                                                       panelImageView.image.size.height)
                         afterScreenUpdates:YES];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return result;
}

- (void)sendMessage
{
    UIImage *preparedPanel = [self preparePanel];
    UIImage *imagePanel = [[[preparedPanel addWatermark:@"watermark.png"] addGutterSize:Gutter] resizeToRatio:4/3.0];
    
    mmsvc = [[MMSViewController alloc] initWithPanel:panel
                                          imagePanel:imagePanel];
    
    if ([mmsvc canSendPanel]) {
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            [self resignFirstResponder];
        }
        
        [self presentViewController:mmsvc animated:YES completion:nil];
    }
}

- (void)share
{
    UIImage *preparedPanel = [self preparePanel];
    UIImage *imagePanel = [[preparedPanel addWatermark:@"watermark.png"] addGutterSize:Gutter];
    
    UIActivityViewController *svc = [[ShareViewController alloc] initWithPanel:panel
                                                                    imagePanel:imagePanel];
    
    if ([Helper isIPhoneDevice]) {
        [self presentViewController:svc animated:YES completion:nil];
        
    } else {
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            
            popupShare = [[UIPopoverController alloc] initWithContentViewController:svc];

            [popupShare presentPopoverFromRect:CGRectMake(self.view.frame.size.width / 2,
                                                          self.view.frame.size.height / 2,
                                                          0,
                                                          0)
                                        inView:self.view
                 permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

        } else {
            [self presentViewController:svc animated:YES completion:nil];
        }
    }
}

- (void)messageSentAnimation
{
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"message_send_success"
                                                           label:panel.panelId
                                                           value:@([balloonsOverlay charactersCount])] build]];
    
    [UIView animateWithDuration:TransitionDuration * 2 animations:^{
        panelView.alpha = 0;
        panelView.center = CGPointMake(self.view.center.x, -panelView.center.y);
        
    } completion:^(BOOL finished) {
        [self.view removeKeyboardControl];
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

@end
