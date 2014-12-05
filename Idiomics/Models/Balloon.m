//
//  Balloon.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/1/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "Balloon.h"
#import <ReactiveCocoa.h>

@interface Balloon ()

@property (nonatomic, copy, readwrite) UIColor *backgroundColor;
@property (nonatomic, assign, readwrite) CGRect rect;
@property (nonatomic, assign, readwrite) CGRect boundsRect;
@property (nonatomic, copy, readwrite) NSArray *polygon;

@end

@implementation Balloon


#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"backgroundColor": @"bg_color",
             @"rect": @"rect",
             @"boundsRect": @"bound_rect",
             @"polygon": NSNull.null
             };
}

+ (NSValueTransformer *)backgroundColorJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *rgb) {
        
        NSScanner *scanner = [NSScanner scannerWithString:rgb];
        NSString *junk, *red, *green, *blue;
        [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&junk];
        [scanner scanUpToCharactersFromSet:[NSCharacterSet punctuationCharacterSet] intoString:&red];
        [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&junk];
        [scanner scanUpToCharactersFromSet:[NSCharacterSet punctuationCharacterSet] intoString:&green];
        [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&junk];
        [scanner scanUpToCharactersFromSet:[NSCharacterSet punctuationCharacterSet] intoString:&blue];
        
        UIColor *backgroundColor = [UIColor colorWithRed:red.intValue/255.0
                                                   green:green.intValue/255.0
                                                    blue:blue.intValue/255.0
                                                   alpha:1.0];
        return backgroundColor;
        
    } reverseBlock:^id(UIColor *backgroundColor) {
        
        CGFloat red, green, blue, alpha;
        [backgroundColor getRed: &red green: &green blue: &blue alpha: &alpha];
        
        return [NSString stringWithFormat:@"rgb(%d, %d, %d)", (unsigned int)red, (unsigned int)green, (unsigned int)blue];
    }];
}

+ (NSValueTransformer *)rectJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSArray *rect) {
        
        return [NSValue valueWithCGRect:CGRectMake(roundf([rect[0] floatValue] / [[UIScreen mainScreen] scale]),
                                                   roundf([rect[1] floatValue] / [[UIScreen mainScreen] scale]),
                                                   roundf([rect[2] floatValue] / [[UIScreen mainScreen] scale]),
                                                   roundf([rect[3] floatValue] / [[UIScreen mainScreen] scale]))];
        
    } reverseBlock:^id(NSValue *rect) {
        
        CGRect res = [rect CGRectValue];
        
        return @[@(res.origin.x * [[UIScreen mainScreen] scale]),
                 @(res.origin.y * [[UIScreen mainScreen] scale]),
                 @(res.size.width * [[UIScreen mainScreen] scale]),
                 @(res.size.height * [[UIScreen mainScreen] scale])];
    }];
}

+ (NSValueTransformer *)boundsRectJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSArray *boundsRect) {
            
        return [NSValue valueWithCGRect:CGRectMake(roundf([boundsRect[0] floatValue] / [[UIScreen mainScreen] scale]),
                                                   roundf([boundsRect[1] floatValue] / [[UIScreen mainScreen] scale]),
                                                   roundf([boundsRect[2] floatValue] / [[UIScreen mainScreen] scale]),
                                                   roundf([boundsRect[3] floatValue] / [[UIScreen mainScreen] scale]))];
        
    } reverseBlock:^id(NSValue *boundsRect) {
            
        CGRect res = [boundsRect CGRectValue];
        
        return @[@(res.origin.x * [[UIScreen mainScreen] scale]),
                 @(res.origin.y * [[UIScreen mainScreen] scale]),
                 @(res.size.width * [[UIScreen mainScreen] scale]),
                 @(res.size.height * [[UIScreen mainScreen] scale])];
    }];
}

@end
