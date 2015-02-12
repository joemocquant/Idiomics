//
//  Balloon.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/1/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "Balloon.h"
#import "RectTransformer.h"

@interface Balloon ()

@property (nonatomic, copy, readwrite) UIColor *backgroundColor;
@property (nonatomic, assign, readwrite) CGRect rect;
@property (nonatomic, assign, readwrite) CGRect boundsRect;
@property (nonatomic, copy, readwrite) NSArray *polygon;

@end

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
    return @{@"backgroundColor": @"bg_color",
             @"rect": @"rect",
             @"boundsRect": @"bound_rect",
             @"polygon": @"polygon"
             };
}

+ (NSValueTransformer *)backgroundColorJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:ColorTransformerName];
}

+ (NSValueTransformer *)rectJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:RectTransformerName];
}

+ (NSValueTransformer *)boundsRectJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:RectTransformerName];
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

@end
