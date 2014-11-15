//
//  PanelViewController.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/11/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Panel.h"
#import "MessageBar.h"
#import <MessageUI/MessageUI.h>

@interface PanelViewController : UIViewController <UIScrollViewDelegate, MessageBarDelegate>
{
    Panel *panel;
    UIScrollView *panelScrollView;
    UIImageView *panelImageView;
    NSMutableArray *speechBalloons;
}

- (instancetype)initWithPanel:(Panel *)p;

@end
