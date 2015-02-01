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

@class Panel;

@interface PanelViewController : TrackingViewController <UIScrollViewDelegate>
{
    Panel *panel;
    UIScrollView *panelScrollView;
    UIView *panelView;
    UIImageView *panelImageView;
    BalloonsOverlay *balloonsOverlay;
    
    CGFloat screenScale;
    NSLayoutConstraint *navigationViewConstraint;
    BOOL keyboardIsPoppingUp;
    CGFloat keyboardOffset;
}

- (instancetype)initWithPanel:(Panel *)p;
- (void)messageSentAnimation;

@end
