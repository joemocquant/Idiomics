//
//  UIColor+Tools.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/14/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "UIColor+Tools.h"

@implementation UIColor (Tools)

//@"rgb(%d, %d, %d)"
+ (UIColor *)colorWithRGBString:(NSString *)color
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

+ (NSString *)RGBStringFromColor:(UIColor *)color
{
    CGFloat red, green, blue, alpha;
    
    [color getRed: &red green: &green blue: &blue alpha: &alpha];
    
    return [NSString stringWithFormat:@"rgb(%d, %d, %d)",
            (unsigned int)red,
            (unsigned int)green,
            (unsigned int)blue];
}

- (UIColor *)darkenColorWithPercentOfOriginal:(CGFloat)amount
{
    float percentage = amount / 100.0; //keep x% of original color
    long   totalComponents = CGColorGetNumberOfComponents(self.CGColor);
    bool  isGreyscale = totalComponents == 2 ? YES : NO;
    
    CGFloat* oldComponents = (CGFloat *)CGColorGetComponents(self.CGColor);
    CGFloat newComponents[4];
    
    if (isGreyscale) {
        newComponents[0] = oldComponents[0] * percentage;
        newComponents[1] = oldComponents[0] * percentage;
        newComponents[2] = oldComponents[0] * percentage;
        newComponents[3] = oldComponents[1];
    } else {
        newComponents[0] = oldComponents[0] * percentage;
        newComponents[1] = oldComponents[1] * percentage;
        newComponents[2] = oldComponents[2] * percentage;
        newComponents[3] = oldComponents[3];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *retColor = [UIColor colorWithCGColor:newColor];
    CGColorRelease(newColor);
    
    return retColor;
}

@end
