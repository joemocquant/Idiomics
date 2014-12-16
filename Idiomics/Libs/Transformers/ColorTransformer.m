//
//  ColorTransformer.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/10/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "ColorTransformer.h"
#import "UIColor+Tools.h"

@implementation ColorTransformer

+ (Class)transformedValueClass
{
    return [UIColor class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(NSString *)color
{
    return [UIColor colorWithRGBString:color];
}

- (id)reverseTransformedValue:(UIColor *)color
{
    return [UIColor RGBStringFromColor:color];
}

@end
