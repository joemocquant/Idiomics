//
//  Panel.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "Panel.h"
#import "PanelImageStore.h"
#import <ReactiveCocoa.h>

@interface Panel ()

@property (nonatomic, copy, readwrite) NSString *panelId;
@property (nonatomic, assign, readwrite) CGSize dimensions;
@property (nonatomic, copy, readwrite) NSString *imageUrl;
@property (nonatomic, copy, readwrite) NSArray *balloons;
@property (nonatomic, copy, readwrite) UIColor *averageColor;

@end

@implementation Panel


#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"panelId": @"_id",
             @"dimensions": @"dimensions",
             @"imageUrl": @"image_url",
             @"balloons": @"balloons",
             @"averageColor": @"avg_color"
             };
}

+ (NSValueTransformer *)dimensionsJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSArray *dimensions) {
        return [NSValue valueWithCGSize:CGSizeMake([dimensions[0] floatValue], [dimensions[1] floatValue])];
        
    } reverseBlock:^id(NSValue *dimensions) {
        
        CGSize size = [dimensions CGSizeValue];
        return @[@(size.width), @(size.height)];
    }];
}

+ (NSValueTransformer *)balloonsJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSArray *balloons) {
        
        NSArray *result = [[[balloons rac_sequence] map:^id(NSArray *balloon) {
            
            return [NSValue valueWithCGRect:CGRectMake([balloon[0] floatValue] / [[UIScreen mainScreen] scale],
                                                       [balloon[1] floatValue] / [[UIScreen mainScreen] scale],
                                                       [balloon[2] floatValue] / [[UIScreen mainScreen] scale],
                                                       [balloon[3] floatValue] / [[UIScreen mainScreen] scale])];
            
        }] array];
        
        return result;
        
    } reverseBlock:^id(NSArray *balloons) {
        
        NSArray *result = [[[balloons rac_sequence] map:^id(NSValue *balloon) {
            
            CGRect res = [balloon CGRectValue];
            return @[@(res.origin.x * [[UIScreen mainScreen] scale]),
                     @(res.origin.y * [[UIScreen mainScreen] scale]),
                     @(res.size.width * [[UIScreen mainScreen] scale]),
                     @(res.size.height * [[UIScreen mainScreen] scale])];
            
        }] array];
        
        return result;

    }];
}

+ (NSValueTransformer *)averageColorJSONTransformer
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
        
        UIColor *averageColor = [UIColor colorWithRed:red.intValue/255.0 green:green.intValue/255.0 blue:blue.intValue/255.0 alpha:1.0];
        return averageColor;
        
    } reverseBlock:^id(UIColor *averageColor) {
        
        CGFloat red, green, blue, alpha;
        [averageColor getRed: &red green: &green blue: &blue alpha: &alpha];
        
        return [NSString stringWithFormat:@"rgb(%d, %d, %d)", (unsigned int)red, (unsigned int)green, (unsigned int)blue];
    }];
}


#pragma mark - Getters/setters

- (BOOL)hasImage
{
    return [[PanelImageStore sharedStore] panelImageForKey:self.imageUrl] != nil;
}

- (BOOL)isFailed
{
    return _failed;
}

@end
