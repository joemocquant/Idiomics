//
//  Panel.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "Panel.h"
#import <ReactiveCocoa.h>

@interface Panel ()

@property (nonatomic, copy, readwrite) NSString *panelId;
@property (nonatomic, assign, readwrite) CGSize dimensions;
@property (nonatomic, copy, readwrite) NSURL *imageUrl;
@property (nonatomic, copy, readwrite) NSArray *balloons;

@end

@implementation Panel


#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"panelId": @"_id",
             @"dimensions": @"dimensions",
             @"imageUrl": @"image_url",
             @"balloons": @"balloons"
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

+ (NSValueTransformer *)imageUrlJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)balloonsJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSArray *balloons) {
        
        NSArray *result = [[[balloons rac_sequence] map:^id(NSArray *balloon) {
            
            return [NSValue valueWithCGRect:CGRectMake([balloon[0] floatValue],
                                                       [balloon[1] floatValue],
                                                       [balloon[2] floatValue],
                                                       [balloon[3] floatValue])];
            
        }] array];
        
        return result;
        
    } reverseBlock:^id(NSArray *balloons) {
        
        NSArray *result = [[[balloons rac_sequence] map:^id(NSValue *balloon) {
            
            CGRect res = [balloon CGRectValue];
            return @[@(res.origin.x), @(res.origin.y), @(res.size.width), @(res.size.height)];
            
        }] array];
        
        return result;

    }];
}

@end
