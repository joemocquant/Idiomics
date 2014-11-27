//
//  PanelViewController.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/11/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageBar.h"

@class Panel;

@interface PanelViewController : UIViewController <UIScrollViewDelegate, MessageBarDelegate>
{
    Panel *panel;
    UIScrollView *panelScrollView;
    UIImageView *panelImageView;
    NSMutableArray *speechBalloons;
    CGFloat minScale;
    CGFloat screenScale;
}

- (instancetype)initWithPanel:(Panel *)p;

@end
