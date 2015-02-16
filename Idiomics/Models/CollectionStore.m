//
//  CollectionStore.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/15/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "CollectionStore.h"

@implementation CollectionStore


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

- (NSMutableArray *)allCollections
{
    if (!allCollections) {
        allCollections = [NSMutableArray array];
    }
    
    return allCollections;
}

- (void)addCollection:(Collection *)collection
{
    [self.allCollections addObject:collection];
}

- (Collection *)collectionAtIndex:(NSUInteger)index
{
    return [self.allCollections objectAtIndex:index];
}

- (void)deleteCurrentCollection
{
    [self.allCollections removeObject:self.currentCollection];
    self.currentCollection = nil;
}

@end
