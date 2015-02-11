//
//  ImageStore.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "ImageStore.h"

@implementation ImageStore


#pragma mark - Class methods

+ (instancetype)sharedStore
{
    static dispatch_once_t once;
    static id sharedStore;
    
    dispatch_once(&once, ^{
        
        if (!sharedStore) {
            sharedStore = [self new];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didReceiveMemoryWarning)
                                                         name:UIApplicationDidReceiveMemoryWarningNotification
                                                       object:nil];
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
    UIImage *image = [[self.imageDictionary objectForKey:key] objectForKey:@"thumb"];
    if (!image) {
        return [self panelFullSizeImageForKey:key];
    }
    
    return image;
}

- (void)addPanelThumbImage:(UIImage *)image forKey:(NSString *)key
{
    [self.imageDictionary setValue:@{@"thumb": image} forKey:key];
}

- (UIImage *)panelFullSizeImageForKey:(NSString *)key
{
    return [[self.imageDictionary objectForKey:key] objectForKey:@"fullSize"];
}

- (UIImage *)panelImageForKey:(NSString *)key
{
    if ([self panelFullSizeImageForKey:key]) {
        return [self panelFullSizeImageForKey:key];
    }
    
    return [self panelThumbImageForKey:key];
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


#pragma mark - Notifications

- (void)didReceiveMemoryWarning
{
    imageDictionary = nil;
}

@end
