//
//  PanelImageStore.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "PanelImageStore.h"
#import <ReactiveCocoa.h>

@implementation PanelImageStore


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

- (NSMutableDictionary *)panelImageDictionary
{
    if (!panelImageDictionary) {
        panelImageDictionary = [NSMutableDictionary dictionary];
    }
    
    return panelImageDictionary;
}


#pragma mark - Instance methods

- (UIImage *)panelThumbImageForKey:(NSString *)s
{
    return [[self.panelImageDictionary objectForKey:s] objectForKey:@"thumb"];
}

- (void)addPanelThumbImage:(UIImage *)panelImage forKey:(NSString *)key
{
    [self.panelImageDictionary setValue:@{@"thumb": panelImage} forKey:key];
}

- (UIImage *)panelFullSizeImageForKey:(NSString *)s
{
    return [[self.panelImageDictionary objectForKey:s] objectForKey:@"fullSize"];
}

- (void)addPanelFullSizeImage:(UIImage *)panelImage forKey:(NSString *)key
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[self.panelImageDictionary objectForKey:key]];
    [dictionary setObject:panelImage forKey:@"fullSize"];

    [self.panelImageDictionary setValue:dictionary forKey:key];
}

- (void)deletePanelImageForKey:(NSString *)s
{
    [self.panelImageDictionary removeObjectForKey:s];
}

- (void)deletePanelImageDicitonary
{
    [self.panelImageDictionary removeAllObjects];
}

@end
