//
//  PanelViewController.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/11/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "PanelViewController.h"
#import "Colors.h"
#import "Fonts.h"
#import "Panel.h"
#import "PanelImageStore.h"
#import "MMSViewController.h"
#import "FocusOverlayView.h"
#import <UIView+AutoLayout.h>

@implementation PanelViewController


#pragma mark - Initialization

- (instancetype)initWithPanel:(Panel *)p
{
    self = [super init];
    
    if (self) {
        panel = p;
        focus = -1;
        
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
    
    panelScrollView = [UIScrollView new];
    [panelScrollView setDelegate:self];
    [panelScrollView setShowsHorizontalScrollIndicator:NO];
    [panelScrollView setShowsVerticalScrollIndicator:NO];
    
    [self.view setBackgroundColor:[panel.averageColor colorWithAlphaComponent:AlphaBackground]];
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

    [self setupNavigationControl];
    [self setupSpeechBalloons];
    [self setupScalesWithContentSize:panelScrollView.contentSize];

    [panelScrollView setZoomScale:screenScale * ScaleFactor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextViewDelefate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSLog(@"a");
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"b");
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"range: %lu %lu with text <%@>", (unsigned long)range.location, (unsigned long)range.length, text);
    return YES;
}


#pragma mark - Gestures

- (void)PanelScrollViewTappedOnce:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:panelImageView];
    __block BOOL found = NO;
    
    [panel.balloons enumerateObjectsUsingBlock:^(NSValue *balloonValue, NSUInteger idx, BOOL *stop) {
        
        if (CGRectContainsPoint([balloonValue CGRectValue], location)) {
            
            focus = idx;
            
            if ([[speechBalloons objectAtIndex:idx] isFirstResponder]) {
                *stop = YES;
            } else {
                [focusOverlays[focus] setAlpha:AlphaFocusForeground];
                [[speechBalloons objectAtIndex:idx] becomeFirstResponder];
                [navigationControl setAlpha:0.0];
                found = YES;
            }
        }
    }];
    
    if (!found) {
        
        if (focus != -1) {
            [focusOverlays[focus] setAlpha:AlphaFocusBackground];
            [[speechBalloons objectAtIndex:focus] resignFirstResponder];
            focus = -1;
        } else {
            [self toggleNavigationControl];
        }
    }
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


#pragma mark - Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    [[notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];
    [self resizeScrollView];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    keyboardBounds = CGRectZero;
    [self resizeScrollView];
}


#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {

        [self centerScrollViewContents];
        
        [panelScrollView setContentSize:CGSizeMake(panelImageView.frame.size.width + 2 * Gutter,
                                                   panelImageView.frame.size.height + 2 * Gutter)];
        
        [self setupScalesWithContentSize:panelScrollView.contentSize];
        
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
    [panelScrollView setFrame:CGRectMake(0,
                                         0,
                                         CGRectGetWidth(screen),
                                         CGRectGetHeight(screen) - keyboardBounds.size.height)];

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

- (void)setupNavigationControl
{
    navigationControl = [UIView new];
    [navigationControl setAlpha:0.0];
    [self.view addSubview:navigationControl];
    
    [navigationControl setTranslatesAutoresizingMaskIntoConstraints:NO];
    [navigationControl pinEdges:JRTViewPinLeftEdge | JRTViewPinBottomEdge | JRTViewPinRightEdge
              toSameEdgesOfView:self.view];
    
    [navigationControl constrainToHeight:NavigationControlHeight];
    [navigationControl setBackgroundColor:[Colors black]];
     CGSize buttonSize = CGSizeMake(NavigationControlHeight, NavigationControlHeight);
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancel setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [navigationControl addSubview:cancel];
    
    [cancel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [cancel constrainToSize:buttonSize];
    [cancel pinEdges:JRTViewPinLeftEdge | JRTViewPinBottomEdge toSameEdgesOfView:navigationControl];
    
    UIButton *send = [UIButton buttonWithType:UIButtonTypeCustom];
    [send setImage:[UIImage imageNamed:@"send.png"] forState:UIControlStateNormal];
    [send addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [navigationControl addSubview:send];
    
    [send setTranslatesAutoresizingMaskIntoConstraints:NO];
    [send constrainToSize:buttonSize];
    [send pinEdges:JRTViewPinRightEdge | JRTViewPinBottomEdge toSameEdgesOfView:navigationControl];
}
                                           
- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toggleNavigationControl
{
    [UIView animateWithDuration:NavigationControlDuration animations:^{
        if (navigationControl.alpha) {
            [navigationControl setAlpha:0.0];
            for (UIView *focusOverlay in focusOverlays) {
                [focusOverlay setAlpha:AlphaFocusBackground];
            }
        } else {
            [navigationControl setAlpha:NavigationControlAlpha];
            for (UIView *focusOverlay in focusOverlays) {
                [focusOverlay setAlpha:0.0];
            }
        }
    }];
}

- (void)setupSpeechBalloons
{
    speechBalloons = [NSMutableArray array];
    focusOverlays = [NSMutableArray array];
    
    for (NSValue *balloon in panel.balloons) {
        CGRect balloonRect = [balloon CGRectValue];
        
        UITextView *ballonTextView = [[UITextView alloc] init];
        [panelImageView addSubview:ballonTextView];
        
        [ballonTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [ballonTextView constrainToSize:balloonRect.size];
        
        [ballonTextView pinEdges:JRTViewPinLeftEdge toSameEdgesOfView:panelImageView inset:balloonRect.origin.x];
        [ballonTextView pinEdges:JRTViewPinTopEdge toSameEdgesOfView:panelImageView inset:balloonRect.origin.y];
        
        [ballonTextView setTextAlignment:NSTextAlignmentCenter];
        [ballonTextView setFont:[Fonts laffayetteComicPro14]];
        [ballonTextView setTextColor:[Colors gray5]];
        [ballonTextView setTintColor:[Colors gray5]];
        [ballonTextView setBackgroundColor:[Colors clear]];
        
        [ballonTextView setDelegate:self];
        [speechBalloons addObject:ballonTextView];
        
        FocusOverlayView *fov = [[FocusOverlayView alloc] init];
        [fov setFrame:balloonRect];
        [panelImageView addSubview:fov];
        [focusOverlays addObject:fov];
    }
}

- (void)resizeScrollView
{
    [UIView animateWithDuration:KeyboardMoveDuration animations:^{
        
        [self centerScrollViewContents];
        CGSize size = CGSizeMake(panelImageView.frame.size.width + 2 * Gutter,
                                 panelImageView.frame.size.height + 2 * Gutter);
        [self setupScalesWithContentSize:size];
        
        if (keyboardBounds.size.height) {
            
            if ([panelScrollView zoomScale] < screenScale) {
                [panelScrollView setZoomScale:screenScale];
            } else {
                [panelScrollView setZoomScale:panelScrollView.zoomScale];
            }
            
        }
    } completion:^(BOOL finished) {
        if (keyboardBounds.size.height) {
            [UIView animateWithDuration:ScrollToBottomDuration animations:^{
                [self focusOnBalloon];
            }];
        }
    }];
}

- (void)focusOnBalloon
{
    CGRect balloon = [[speechBalloons objectAtIndex:focus] frame];
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
}

-(void)setupScalesWithContentSize:(CGSize)contentSize
{
    // Set up the minimum & maximum zoom scales
    
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

- (void)sendMessage
{
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
    
    [panelImageView drawViewHierarchyInRect:panelImageView.frame afterScreenUpdates:YES];
    
    UIImage *editedPanel = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    MMSViewController *mmsvc = [[MMSViewController alloc] initWithEditedPanel:editedPanel];
    
    if ([mmsvc canSendPanel]) {
        
        [mmsvc setModalTransitionStyle:UIModalTransitionStylePartialCurl];
        [self presentViewController:mmsvc animated:YES completion:nil];
    }
}

@end
