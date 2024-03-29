//
//  PanelViewController.h
//  Idiomics
//
//  Created by Joe Mocquant on 11/11/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackingViewController.h"

@class BalloonsOverlay;
@class NavigationView;
@class MMSViewController;

@class Panel;

@interface PanelViewController : TrackingViewController <UIScrollViewDelegate, UIPopoverControllerDelegate>
{
    Panel *panel;
    UIScrollView *panelScrollView;
    UIView *panelView;
    UIImageView *panelImageView;
    BalloonsOverlay *balloonsOverlay;
    UIButton *share;
    
    CGFloat screenScale;
    NSLayoutConstraint *navigationViewConstraint;
    BOOL keyboardIsPoppingUp;
    CGFloat keyboardOffset;
    MMSViewController *mmsvc;
    UIPopoverController *popupShare;
}

- (instancetype)initWithPanel:(Panel *)p;
- (void)messageSentAnimation;

@end
