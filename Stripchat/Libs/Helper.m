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

+ (CGSize)getMinPanelSize
{
    NSString *deviceType = [UIDevice currentDevice].model;
    CGRect screen = [[UIScreen mainScreen] bounds];
    
    CGFloat width;
    CGFloat height;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        width = CGRectGetWidth(screen);
        height = CGRectGetHeight(screen);
    } else {
        width = CGRectGetHeight(screen);
        height = CGRectGetWidth(screen);
    }
    
    CGFloat minWidth;
    if ([deviceType isEqualToString:@"iPhone"]) {
        minWidth = MAX(roundf(width / kColumnsiPhonePortrait),
                       roundf(height / kColumnsiPhoneLandscape));

    } else {
        minWidth = MAX(roundf(width / kColumnsiPadPortrait),
                       roundf(height / kColumnsiPadLandscape));
    }

    NSUInteger scaleFactor = scaleFactor = [[UIScreen mainScreen] scale];
    
    return CGSizeMake(minWidth * 2 * scaleFactor, minWidth * 2 * scaleFactor);
}

+ (NSString *)getImageWithUrl:(NSString *)url witdh:(NSUInteger)width height:(NSUInteger)height
{
    NSUInteger scaleFactor = 1;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scaleFactor = [[UIScreen mainScreen] scale];
    }
    
    NSString *imageProxyServerUrl = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ImageProxy-Server-URL"];
    NSString *result = [NSString stringWithFormat:@"%@/resize/%lux%lu/%@",
                        imageProxyServerUrl,
                        width * scaleFactor,
                        height * scaleFactor,
                        url];
    
    return result;
}

@end
