//
//  PanelViewController.h
//  Idiomics
//
//  Created by Joe Mocquant on 11/11/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackingViewController.h"
#import "BalloonsOverlay.h"

@class Panel;
@class NavigationView;

@interface PanelViewController : TrackingViewController <UIScrollViewDelegate, BalloonOverlayDelegate>
{
    Panel *panel;
    UIScrollView *panelScrollView;
    UIView *panelView;
    UIImageView *panelImageView;
    BalloonsOverlay *balloonsOverlay;
    
    NavigationView *navigationView;
    
    CGFloat screenScale;
    NSUInteger focus;
    CGFloat keyboardOffset;
}

- (instancetype)initWithPanel:(Panel *)p;

@end
