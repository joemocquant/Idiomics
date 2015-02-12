//
//  RectTransformer.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/10/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "RectTransformer.h"

@implementation RectTransformer

+ (Class)transformedValueClass
{
    return [NSValue class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(NSArray *)rect
{
    return [NSValue valueWithCGRect:CGRectMake(roundf([rect[0] floatValue] / [UIScreen mainScreen].scale),
                                               roundf([rect[1] floatValue] / [UIScreen mainScreen].scale),
                                               roundf([rect[2] floatValue] / [UIScreen mainScreen].scale),
                                               roundf([rect[3] floatValue] / [UIScreen mainScreen].scale))];
}

- (id)reverseTransformedValue:(NSValue *)rect
{
    CGRect res = [rect CGRectValue];
    
    return @[@(res.origin.x * [UIScreen mainScreen].scale),
             @(res.origin.y * [UIScreen mainScreen].scale),
             @(res.size.width * [UIScreen mainScreen].scale),
             @(res.size.height * [UIScreen mainScreen].scale)];
}

@end
