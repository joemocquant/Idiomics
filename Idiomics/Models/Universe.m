//
//  Universe.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/14/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "Universe.h"
#import "ColorTransformer.h"
#import "ImageStore.h"
#import "Panel.h"

@interface Universe ()

@property (nonatomic, copy, readwrite) NSString *universeId;
@property (nonatomic, copy, readwrite) NSString *imageUrl;
@property (nonatomic, copy, readwrite) UIColor *averageColor;

@end

@implementation Universe


#pragma mark - Lifecycle

+ (void)initialize
{
    if (self == Universe.class) {
        ColorTransformer *transformer = [ColorTransformer new];
        [NSValueTransformer setValueTransformer:transformer forName:ColorTransformerName];
    }
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        allPanels = [NSMutableArray array];
    }
    
    return self;
}


#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"universeId": @"_id",
             @"imageUrl": @"cover_url",
             @"averageColor": @"cover_avg_color"
             };
}

+ (NSValueTransformer *)averageColorJSONTransformer
{
    return [MTLValueTransformer valueTransformerForName:ColorTransformerName];
}


#pragma mark - Getters/setters

- (BOOL)hasCoverImage
{
    return [[ImageStore sharedStore] universeImageForKey:self.imageUrl] != nil;
}

- (BOOL)isFailed
{
    return _failed;
}


#pragma mark - Instance methods

- (NSMutableArray *)allPanels
{
    if (!allPanels) {
        allPanels = [NSMutableArray array];
    }
    
    return allPanels;
}

- (void)addPanel:(Panel *)panel
{
    [self.allPanels addObject:panel];
}

- (Panel *)panelAtIndex:(NSUInteger)index
{
    return [self.allPanels objectAtIndex:index];
}

- (void)deleteAllPanels
{
    for (Panel *panel in allPanels) {
        [[ImageStore sharedStore] deleteImagesForKey:panel.imageUrl];
    }
    
    [self.allPanels removeAllObjects];
}

@end
