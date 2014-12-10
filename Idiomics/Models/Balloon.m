//
//  Balloon.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/1/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "Balloon.h"
#import "RectTransformer.h"
#import <ReactiveCocoa.h>

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
             @"polygon": NSNull.null
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

@end
