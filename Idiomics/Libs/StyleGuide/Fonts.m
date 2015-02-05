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

+ (UIFont *)komikaDisplayForSize:(CGFloat)size
{
    return [UIFont fontWithName:@"KomikaDisplay" size:size];
}

@end
