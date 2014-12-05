//
//  Helper.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "Helper.h"
#import <Mantle.h>

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
    [[[UIAlertView alloc] initWithTitle:@"Idiomics"
                                message:msg
                               delegate:delegate
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

+ (NSString *)getImageWithUrl:(NSString *)url witdh:(CGFloat)width height:(CGFloat)height
{
    CGFloat scaleFactor = 1;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scaleFactor = [[UIScreen mainScreen] scale];
    }
    
    NSString *imageProxyServerUrl = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ImageProxy-Server-URL"];
    NSString *result = [NSString stringWithFormat:@"%@/resize/%lux%lu/%@",
                        imageProxyServerUrl,
                        (unsigned long)(width * scaleFactor),
                        (unsigned long)(height * scaleFactor),
                        url];
    
    return result;
}

+ (BOOL)isIPhoneDevice
{
    if ([[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {

        return YES;
    }

    return NO;
}

@end
