//
//  ColorTransformer.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/10/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "ColorTransformer.h"

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
    NSScanner *scanner = [NSScanner scannerWithString:color];
    
    NSString *junk, *red, *green, *blue;
    
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&junk];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet punctuationCharacterSet] intoString:&red];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&junk];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet punctuationCharacterSet] intoString:&green];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&junk];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet punctuationCharacterSet] intoString:&blue];
    
    return [UIColor colorWithRed:red.intValue/255.0
                           green:green.intValue/255.0
                            blue:blue.intValue/255.0
                           alpha:1.0];
}

- (id)reverseTransformedValue:(UIColor *)color
{
    CGFloat red, green, blue, alpha;
    
    [color getRed: &red green: &green blue: &blue alpha: &alpha];
    
    return [NSString stringWithFormat:@"rgb(%d, %d, %d)",
                                    (unsigned int)red,
                                    (unsigned int)green,
                                    (unsigned int)blue];
}

@end
