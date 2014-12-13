//
//  MMSViewController.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/12/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "MMSViewController.h"
#import "Helper.h"
#import "PanelViewController.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import <GAI.h>
#import <GAIDictionaryBuilder.h>

@implementation MMSViewController

- (instancetype)initWithEditedPanel:(UIImage *)imagePanel
                            panelId:(NSString *)pId
{
    self = [super init];
    
    if (self) {
        
        panelId = pId;
        [self setMessageComposeDelegate:self];
        
        NSData *data = UIImageJPEGRepresentation(imagePanel, 1.0);
        [self addAttachmentData:data  typeIdentifier:@"public.data" filename:@"name.jpg"];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    trackingIntervalStart = [NSDate date];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSTimeInterval elapsed = [trackingIntervalStart timeIntervalSinceNow] * -1 * 1000;
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:@"ui_time_spent"
                                                         interval:@(elapsed)
                                                             name:@"message_send_view"
                                                            label:panelId] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - FMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    
    switch (result) {
        case MessageComposeResultCancelled:
        {
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                  action:@"message_cancel"
                                                                   label:panelId
                                                                   value:nil] build]];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case MessageComposeResultFailed:
        {
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                  action:@"message_send_error"
                                                                   label:panelId
                                                                   value:nil] build]];
            
            [Helper showErrorWithMsg:NSLocalizedStringFromTable(@"MESSAGE_SENT_ERROR", @"Idiomics" , nil)
                            delegate:self];
            break;
        }
        case MessageComposeResultSent:
        {
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                  action:@"message_send_success"
                                                                   label:panelId
                                                                   value:nil] build]];
            
            PanelViewController *pvc = (PanelViewController *)self.presentingViewController;
            [self dismissViewControllerAnimated:YES completion:^{
                [pvc messageSentAnimation];
            }];
            break;
        }
        default:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([Helper isIPhoneDevice]) {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark - Instance methods

- (BOOL)canSendPanel
{
    if ([MFMessageComposeViewController canSendText] && [MFMessageComposeViewController canSendAttachments]) {
        return YES;
    } else {
        return NO;
    }
}

@end
