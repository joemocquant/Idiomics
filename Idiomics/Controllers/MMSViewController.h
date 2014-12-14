//
//  MMSViewController.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/12/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class Panel;

@interface MMSViewController : MFMessageComposeViewController <MFMessageComposeViewControllerDelegate,
                                                               UIAlertViewDelegate>
{
    Panel *panel;
    NSDate *trackingIntervalStart;
}

- (instancetype)initWithPanel:(Panel *)p
                   imagePanel:(UIImage *)imagePanel;
- (BOOL)canSendPanel;

@end
