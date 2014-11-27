//
//  Helper.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Helper : NSObject

+ (void)showWarningWithMsg:(NSString *)msg delegate:(id<UIAlertViewDelegate>)delegate;
+ (void)showErrorWithMsg:(NSString *)msg delegate:(id<UIAlertViewDelegate>)delegate;
+ (void)showValidationWithMsg:(NSString *)msg delegate:(id<UIAlertViewDelegate>)delegate;
+ (NSString *)getImageWithUrl:(NSString *)url witdh:(NSUInteger)width height:(NSUInteger)height;
+ (BOOL)isIPhoneDevice;

@end
