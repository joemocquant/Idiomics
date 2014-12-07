//
//  PanelViewController.h
//  Idiomics
//
//  Created by Joe Mocquant on 11/11/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Panel;
@class NavigationView;

@interface PanelViewController : UIViewController <UIScrollViewDelegate, UITextViewDelegate>
{
    Panel *panel;
    UIScrollView *panelScrollView;
    UIView *panelView;
    UIImageView *panelImageView;
    NSMutableArray *speechBalloons;
    NSMutableArray *speechBalloonsLabel;
    NavigationView *navigationView;
    
    CGFloat minScale;
    CGFloat screenScale;
    NSUInteger focus;
    NSMutableArray *focusOverlays;
    CGFloat keyboardOffset;
    
    NSDate *trackingIntervalStart;
}

- (instancetype)initWithPanel:(Panel *)p;

@end
