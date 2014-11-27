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

+ (NSString *)getImageWithUrl:(NSString *)url witdh:(NSUInteger)width height:(NSUInteger)height
{
    NSUInteger scaleFactor = 1;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scaleFactor = [[UIScreen mainScreen] scale];
    }
    
    NSString *imageProxyServerUrl = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ImageProxy-Server-URL"];
    NSString *result = [NSString stringWithFormat:@"%@/resize/%ux%u/%@",
                        imageProxyServerUrl,
                        width * scaleFactor,
                        height * scaleFactor,
                        url];
    
    return result;
}

@end
