//
//  MMSViewController.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/12/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "MMSViewController.h"
#import "Helper.h"

@implementation MMSViewController

- (instancetype)initWithEditedPanel:(UIImage *)imagePanel
{
    self = [super init];
    
    if (self) {
        [self setMessageComposeDelegate:self];
        
        NSData *data = UIImageJPEGRepresentation(imagePanel, 1);
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
            break;
            
        case MessageComposeResultFailed:
            [Helper showErrorWithMsg:NSLocalizedStringFromTable(@"MESSAGE_ERROR", @"Stripchat" , nil)
                            delegate:self];
            break;
            
        case MessageComposeResultSent:
            [Helper showValidationWithMsg:NSLocalizedStringFromTable(@"MESSAGE_SENT", @"Stripchat" , nil)
                                 delegate:self];
            break;
            
        default:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
