//
//  PanelImageStore.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "PanelImageStore.h"
#import "PanelStore.h"
#import "Panel.h"
#import <AFNetworking.h>
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

- (UIImage *)panelImageForKey:(NSString *)s
{
    return [self.panelImageDictionary objectForKey:s];
}

- (void)addPanelImage:(UIImage *)panelImage forKey:(NSString *)key
{
    [self.panelImageDictionary setValue:panelImage forKey:key];
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
