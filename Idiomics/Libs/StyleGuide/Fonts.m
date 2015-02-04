//
//  Fonts.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/10/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "Fonts.h"

@implementation Fonts


#pragma mark - Class methods

+ (UIFont *)helvetica10
{
    return [UIFont fontWithName:@"Helvetica" size:10];
}

+ (UIFont *)helvetica20
{
    return [UIFont fontWithName:@"Helvetica" size:20];
}

+ (UIFont *)helveticaNeueLight20
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
}

+ (UIFont *)laffayetteComicPro18
{
    return [UIFont fontWithName:@"LaffayetteComicPro" size:18];
}

+ (UIFont *)laffayetteComicPro30
{
    return [UIFont fontWithName:@"LaffayetteComicPro" size:30];
}

+ (UIFont *)kronika18
{
    return [UIFont fontWithName:@"Kronika" size:18];
}

+ (UIFont *)kronikaForSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Kronika" size:size];
}

@end
