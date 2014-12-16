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
#import "Panel.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import <GAI.h>
#import <GAIDictionaryBuilder.h>
#import <GAIFields.h>

@implementation MMSViewController

- (instancetype)initWithPanel:(Panel *)p
                   imagePanel:(UIImage *)imagePanel

{
    self = [super init];
    
    if (self) {
        
        panel = p;
        [self setMessageComposeDelegate:self];
        NSData *data = UIImageJPEGRepresentation(imagePanel, 1.0);
        [self addAttachmentData:data  typeIdentifier:@"public.data" filename:@"name.jpg"];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    trackingIntervalStart = [NSDate date];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"message_send"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSInteger elapsed = [trackingIntervalStart timeIntervalSinceNow] * -1 * 1000;
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:@"ui_time_spent"
                                                         interval:@(elapsed)
                                                             name:@"message_send"
                                                            label:panel.panelId] build]];
    
    [tracker set:kGAIScreenName value:nil];
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
                                                                   label:panel.panelId
                                                                   value:nil] build]];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case MessageComposeResultFailed:
        {
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                  action:@"message_send_error"
                                                                   label:panel.panelId
                                                                   value:nil] build]];
            
            [Helper showErrorWithMsg:NSLocalizedStringFromTable(@"MESSAGE_SENT_ERROR", @"Idiomics" , nil)
                            delegate:self];
            break;
        }
        case MessageComposeResultSent:
        {   
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
