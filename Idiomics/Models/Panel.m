//
//  Panel.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "Panel.h"
#import "Balloon.h"
#import "ImageStore.h"

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
        return [NSValue valueWithCGSize:CGSizeMake(roundf([dimensions[0] floatValue] / [[UIScreen mainScreen] scale]),
                                                   roundf([dimensions[1] floatValue] / [[UIScreen mainScreen] scale]))];
        
    } reverseBlock:^id(NSValue *dimensions) {
        
        CGSize size = [dimensions CGSizeValue];
        return @[@(size.width * [[UIScreen mainScreen] scale]),
                 @(size.height * [[UIScreen mainScreen] scale])];
    }];
}

+ (NSValueTransformer *)balloonsJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:Balloon.class];
}

+ (NSValueTransformer *)averageColorJSONTransformer
{
    return [MTLValueTransformer valueTransformerForName:ColorTransformerName];
}


#pragma mark - Getters/setters

- (BOOL)hasThumbImage
{
    return [[ImageStore sharedStore] panelThumbImageForKey:self.imageUrl] != nil;
}

- (BOOL)hasFullSizeImage
{
    return [[ImageStore sharedStore] panelFullSizeImageForKey:self.imageUrl] != nil;
}

- (BOOL)isFailed
{
    return _failed;
}

@end
