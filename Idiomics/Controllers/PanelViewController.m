//
//  PanelViewController.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/11/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "PanelViewController.h"
#import "Colors.h"
#import "Fonts.h"
#import "Panel.h"
#import "Balloon.h"
#import "PanelImageStore.h"
#import "NavigationView.h"
#import "MMSViewController.h"
#import "FocusOverlayView.h"
#import <UIView+AutoLayout.h>

@implementation PanelViewController


#pragma mark - Initialization

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (UIView *)inputAccessoryView
{
    if (!navigationView) {
        [self setupNavigationView];
    }
    
    return navigationView;
}

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
    
    [self setupSpeechBalloons];
    [self setupScalesWithContentSize:panelScrollView.contentSize];

    [panelScrollView setZoomScale:screenScale * ScaleFactor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextViewDelegate

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

- (void)textViewDidChange:(UITextView *)textView
{
    UILabel *currentLabel = [speechBalloonsLabel objectAtIndex:focus];
    [currentLabel setText:textView.text];
    
    navigationView.isEdited = NO;
    [speechBalloonsLabel enumerateObjectsUsingBlock:^(UILabel *obj, NSUInteger idx, BOOL *stop) {
        if (obj.text && ![obj.text isEqualToString:@""]) {
            navigationView.isEdited = YES;
            *stop = YES;
        }
    }];
    
    [navigationView updateVisibility];
}


#pragma mark - Gestures

- (void)PanelScrollViewTappedOnce:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:panelImageView];
    __block BOOL found = NO;
    
    [panel.balloons enumerateObjectsUsingBlock:^(Balloon *balloon, NSUInteger idx, BOOL *stop) {
        
        if (CGRectContainsPoint([balloon rect], location)) {
            //Balloon tapped
            focus = idx;
            
            if ([[speechBalloons objectAtIndex:idx] isFirstResponder]) {
                //Current balloon with focus
                *stop = YES;
                
            } else {
                //Other balloon
                [focusOverlays[focus] setAlpha:AlphaFocusForeground];
                [[speechBalloons objectAtIndex:idx] becomeFirstResponder];

                found = YES;
            }
        }
    }];
    
    if (!found) {
        //Other part was tapped
        
        if (focus != -1) {
            //during editing
    
            [focusOverlays[focus] setAlpha:AlphaFocusBackground];
            [[speechBalloons objectAtIndex:focus] resignFirstResponder];
            
            focus = -1;
            
        } else {
            //during preview

            if (CGRectContainsPoint(panelImageView.frame, location)) {
                
                if (navigationView.isEdited) {
                    if (!navigationView.alpha) {
                        for (UIView *focusOverlay in focusOverlays) {
                            [focusOverlay setAlpha:0.0];
                        }
                    } else {
                        for (UIView *focusOverlay in focusOverlays) {
                            [focusOverlay setAlpha:AlphaFocusBackground];
                        }
                    }
                }
                [navigationView toggleVisibility];
                
            } else {
                [self back];
            }
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
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];

    if (keyboardBounds.size.height > NavigationControlHeight) {
        keyboardOffset = keyboardBounds.size.height - NavigationControlHeight;
        [self resizeScrollView];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    keyboardOffset = 0.0;
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
                                         CGRectGetHeight(screen) - keyboardOffset)];

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

- (void)toggleBalloonOverlays
{
    [UIView animateWithDuration:NavigationControlDuration animations:^{
        if (navigationView.alpha) {
            for (UIView *focusOverlay in focusOverlays) {
                [focusOverlay setAlpha:AlphaFocusBackground];
            }
        } else {
            for (UIView *focusOverlay in focusOverlays) {
                [focusOverlay setAlpha:0.0];
            }
        }
    }];
}

- (void)setupSpeechBalloons
{
    speechBalloons = [NSMutableArray array];
    speechBalloonsLabel = [NSMutableArray array];
    focusOverlays = [NSMutableArray array];
    
    for (Balloon *balloon in panel.balloons) {
        CGRect balloonRect = [balloon rect];
        
        UITextView *balloonTextView = [UITextView new];
        //UITextView
        [panelImageView addSubview:balloonTextView];
        
        //[balloonTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
        //[balloonTextView constrainToSize:balloonRect.size];
        
        //[balloonTextView pinEdges:JRTViewPinLeftEdge toSameEdgesOfView:panelImageView inset:balloonRect.origin.x];
        //[balloonTextView pinEdges:JRTViewPinTopEdge toSameEdgesOfView:panelImageView inset:balloonRect.origin.y];
        
        [balloonTextView setTextAlignment:NSTextAlignmentCenter];
        [balloonTextView setFont:[Fonts laffayetteComicPro30]];
        [balloonTextView setTextColor:[Colors gray5]];
        [balloonTextView setTintColor:[Colors gray5]];
        [balloonTextView setBackgroundColor:[Colors clear]];
        
        [balloonTextView setDelegate:self];
        
        //UILabel
        UILabel *balloonLabel = [UILabel new];
        [balloonLabel setAdjustsFontSizeToFitWidth:YES];
        //
        
        [speechBalloons addObject:balloonTextView];
        
        FocusOverlayView *fov = [[FocusOverlayView alloc] init];
        [fov setFrame:balloonRect];
        [panelImageView addSubview:fov];
        [focusOverlays addObject:fov];
        
        //UILabel
        [balloonLabel setAdjustsFontSizeToFitWidth:YES];
        [balloonLabel setNumberOfLines:0];
        [balloonLabel setFrame:balloonRect];
        [panelImageView addSubview:balloonLabel];
        [speechBalloonsLabel addObject:balloonLabel];
        [balloonLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [balloonLabel constrainToSize:balloonRect.size];
        
        [balloonLabel pinEdges:JRTViewPinLeftEdge toSameEdgesOfView:panelImageView inset:balloonRect.origin.x];
        [balloonLabel pinEdges:JRTViewPinTopEdge toSameEdgesOfView:panelImageView inset:balloonRect.origin.y];
        [balloonLabel setTextAlignment:NSTextAlignmentCenter];
        [balloonLabel setFont:[Fonts laffayetteComicPro30]];
        [balloonLabel setTextColor:[Colors gray5]];
    }
}

- (void)resizeScrollView
{
    [UIView animateWithDuration:KeyboardMoveDuration animations:^{
        
        [self centerScrollViewContents];
        CGSize size = CGSizeMake(panelImageView.frame.size.width + 2 * Gutter,
                                 panelImageView.frame.size.height + 2 * Gutter);
        [self setupScalesWithContentSize:size];
        
        if (keyboardOffset) {
            
            if ([panelScrollView zoomScale] < screenScale) {
                [panelScrollView setZoomScale:screenScale];
            } else {
                [panelScrollView setZoomScale:panelScrollView.zoomScale];
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

- (void)setupNavigationView
{
    navigationView = [NavigationView new];
    
    [[navigationView cancel] addTarget:self action:@selector(back)
                             forControlEvents:UIControlEventTouchUpInside];
    [[navigationView send] addTarget:self action:@selector(sendMessage)
                           forControlEvents:UIControlEventTouchUpInside];
    
    if (![speechBalloonsLabel count]) {
        [navigationView setIsEdited:YES];
    } else {
        [navigationView setAlpha:0.0];
    }
}

- (void)back
{
    if (focus != -1) {
        [focusOverlays[focus] setAlpha:AlphaFocusBackground];
        [[speechBalloons objectAtIndex:focus] resignFirstResponder];
        
        focus = -1;
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
