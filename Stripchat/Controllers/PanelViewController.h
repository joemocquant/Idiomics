//
//  PanelViewController.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/11/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Panel;

@interface PanelViewController : UIViewController <UIScrollViewDelegate, UITextViewDelegate>
{
    Panel *panel;
    UIScrollView *panelScrollView;
    UIView *panelView;
    UIImageView *panelImageView;
    NSMutableArray *speechBalloons;
    NSMutableArray *speechBalloonsLabel;
    UIView *navigationControl;
    
    CGFloat minScale;
    CGFloat screenScale;
    NSUInteger focus;
    NSMutableArray *focusOverlays;
    CGRect keyboardBounds;
}

- (instancetype)initWithPanel:(Panel *)p;

@end
