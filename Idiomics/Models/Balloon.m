//
//  Balloon.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/1/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "Balloon.h"
#import "RectTransformer.h"

@implementation Balloon


#pragma mark - Lifecycle

+ (void)initialize
{
    if (self == Balloon.class) {
        RectTransformer *transformer = [RectTransformer new];
        [NSValueTransformer setValueTransformer:transformer forName:RectTransformerName];
    }
}

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"polygon": @"polygon",
             @"insideRect": @"inside_rect",
             @"outsideRect": @"outside_rect",
             @"backgroundColor": @"bg_color"
             };
}

+ (NSValueTransformer *)polygonJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSArray *polygon) {
        
        NSMutableArray *res = [NSMutableArray array];
        for(NSArray *p in polygon) {
            CGPoint point = CGPointMake(roundf([p[0] floatValue] / [UIScreen mainScreen].scale),
                                        roundf([p[1] floatValue] / [UIScreen mainScreen].scale));
            [res addObject:[NSValue valueWithCGPoint:point]];
        }
        
        return res;
        
    } reverseBlock:^id(NSArray *polygon) {

        NSMutableArray *res = [NSMutableArray array];
        for (NSValue *point in polygon) {
            NSArray *p = [NSArray arrayWithObjects:@([point CGPointValue].x * [UIScreen mainScreen].scale),
                                                   @([point CGPointValue].y * [UIScreen mainScreen].scale),
                                                   nil];
            [res addObject:p];
        }
        
        return res;
    }];
}

+ (NSValueTransformer *)insideRectJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:RectTransformerName];
}

+ (NSValueTransformer *)outsideRectJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:RectTransformerName];
}

+ (NSValueTransformer *)backgroundColorJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:ColorTransformerName];
}

@end
