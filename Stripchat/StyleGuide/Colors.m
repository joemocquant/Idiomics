//
//  Colors.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/10/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "Colors.h"

@implementation Colors


#pragma mark - Class methods

+ (UIColor *)gray1
{
    return [UIColor colorWithRed:248 / 255.0
                           green:248 / 255.0
                            blue:248 / 255.0
                           alpha:1.0];
}

+ (UIColor *)gray2
{
    return [UIColor colorWithRed:220 / 255.0
                           green:220 / 255.0
                            blue:220 / 255.0
                           alpha:1.0];
}

+ (UIColor *)gray3
{
    return [UIColor lightGrayColor];
}

+ (UIColor *)gray4
{
    return [UIColor grayColor];
}

+ (UIColor *)white
{
    return [UIColor whiteColor];
}

+ (UIColor *)black
{
    return [UIColor blackColor];
}

+ (UIColor *)clear
{
    return [UIColor clearColor];
}

@end
