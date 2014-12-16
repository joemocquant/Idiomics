//
//  ImageStore.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "ImageStore.h"
#import <ReactiveCocoa.h>

@implementation ImageStore


#pragma mark - Class methods

+ (instancetype)sharedStore
{
    static dispatch_once_t once;
    static id sharedStore;
    
    dispatch_once(&once, ^{
        
        if (!sharedStore) {
            sharedStore = [self new];
        }
    });
    
    return sharedStore;
}


#pragma mark - Getters/setters

- (NSMutableDictionary *)imageDictionary
{
    if (!imageDictionary) {
        imageDictionary = [NSMutableDictionary dictionary];
    }
    
    return imageDictionary;
}


#pragma mark - Instance methods

- (UIImage *)panelThumbImageForKey:(NSString *)key
{
    return [[self.imageDictionary objectForKey:key] objectForKey:@"thumb"];
}

- (void)addPanelThumbImage:(UIImage *)image forKey:(NSString *)key
{
    [self.imageDictionary setValue:@{@"thumb": image} forKey:key];
}

- (UIImage *)panelFullSizeImageForKey:(NSString *)key
{
    return [[self.imageDictionary objectForKey:key] objectForKey:@"fullSize"];
}

- (void)addPanelFullSizeImage:(UIImage *)image forKey:(NSString *)key
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[self.imageDictionary objectForKey:key]];
    [dictionary setObject:image forKey:@"fullSize"];

    [self.imageDictionary setValue:dictionary forKey:key];
}

- (UIImage *)universeImageForKey:(NSString *)key
{
    return [self.imageDictionary objectForKey:key];
}

- (void)addUniverseImage:(UIImage *)image forKey:(NSString *)key
{
    [self.imageDictionary setValue:image forKey:key];
}

- (void)deleteImagesForKey:(NSString *)key
{
    [self.imageDictionary removeObjectForKey:key];
}

- (void)deleteImageDicitonary
{
    [self.imageDictionary removeAllObjects];
}

@end
