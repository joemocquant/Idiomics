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
    UIScrollView *panelScrollView;
    UIImageView *panelImageView;
}

@property (nonatomic, strong, readonly) Panel *panel;

- (instancetype)initWithPanel:(Panel *)p;

@end
