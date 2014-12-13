//
//  MMSViewController.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/12/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface MMSViewController : MFMessageComposeViewController <MFMessageComposeViewControllerDelegate,
                                                               UIAlertViewDelegate>
{
    NSString *panelId;
    NSDate *trackingIntervalStart;
}

- (instancetype)initWithEditedPanel:(UIImage *)imagePanel
                            panelId:(NSString *)panelId;
- (BOOL)canSendPanel;

@end
