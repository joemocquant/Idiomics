//
//  PanelStore.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/7/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "PanelStore.h"

@implementation PanelStore


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

@end
