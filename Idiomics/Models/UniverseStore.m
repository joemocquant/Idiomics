//
//  UniverseStore.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/15/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "UniverseStore.h"

@implementation UniverseStore


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

- (NSMutableArray *)allUniverses
{
    if (!allUniverses) {
        allUniverses = [NSMutableArray array];
    }
    
    return allUniverses;
}

- (void)addUniverse:(Universe *)universe
{
    [self.allUniverses addObject:universe];
}

- (Universe *)universeAtIndex:(NSUInteger)index
{
    return [self.allUniverses objectAtIndex:index];
}

@end
