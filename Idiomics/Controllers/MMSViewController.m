//
//  MMSViewController.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/12/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "MMSViewController.h"
#import "Helper.h"
#import <MessageUI/MFMessageComposeViewController.h>

@implementation MMSViewController

- (instancetype)initWithEditedPanel:(UIImage *)imagePanel
{
    self = [super init];
    
    if (self) {
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
            [self dismissViewControllerAnimated:YES completion:nil];
            
            break;
            
        case MessageComposeResultFailed:
            [Helper showErrorWithMsg:NSLocalizedStringFromTable(@"MESSAGE_SENT_ERROR", @"Idiomics" , nil)
                            delegate:self];
            break;
            
        case MessageComposeResultSent:
            [Helper showValidationWithMsg:NSLocalizedStringFromTable(@"MESSAGE_SENT_SUCCESS", @"Idiomics" , nil)
                                 delegate:self];
            break;
            
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