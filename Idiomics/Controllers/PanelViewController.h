//
//  PanelViewController.h
//  Idiomics
//
//  Created by Joe Mocquant on 11/11/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackingViewController.h"

@class Panel;
@class NavigationView;

@interface PanelViewController : TrackingViewController <UIScrollViewDelegate, UITextViewDelegate>
{
    Panel *panel;
    UIScrollView *panelScrollView;
    UIView *panelView;
    UIImageView *panelImageView;
    NSMutableArray *speechBalloons;
    NSMutableArray *speechBalloonsLabel;
    NavigationView *navigationView;
    
    CGFloat screenScale;
    NSUInteger focus;
    NSMutableArray *focusOverlays;
    CGFloat keyboardOffset;
}

- (instancetype)initWithPanel:(Panel *)p;

@end
