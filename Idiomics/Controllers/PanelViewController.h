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

@class Panel;

@interface PanelViewController : TrackingViewController <UIScrollViewDelegate>
{
    Panel *panel;
    UIScrollView *panelScrollView;
    UIView *panelView;
    UIImageView *panelImageView;
    BalloonsOverlay *balloonsOverlay;
    
    CGFloat screenScale;
    CGFloat keyboardOffset;
}

- (instancetype)initWithPanel:(Panel *)p;

@end
