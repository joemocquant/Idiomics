//
//  Helper.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "Helper.h"

@implementation Helper


#pragma mark - Class methods

+ (void)showWarningWithMsg:(NSString *)msg delegate:(id<UIAlertViewDelegate>)delegate
{
    [[[UIAlertView alloc] initWithTitle:@"Warning"
                                message:msg
                               delegate:delegate
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

+ (void)showErrorWithMsg:(NSString *)msg delegate:(id<UIAlertViewDelegate>)delegate
{
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:msg
                               delegate:delegate
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

+ (void)showValidationWithMsg:(NSString *)msg delegate:(id<UIAlertViewDelegate>)delegate
{
    [[[UIAlertView alloc] initWithTitle:@"Stripchat"
                                message:msg
                               delegate:delegate
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

@end
