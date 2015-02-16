//
//  CollectionStore.h
//  Idiomics
//
//  Created by Joe Mocquant on 12/15/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Collection;

@interface CollectionStore : NSObject
{
    NSMutableArray *allCollections;
}

@property (nonatomic, strong) Collection *currentCollection;

+ (instancetype)sharedStore;
- (NSMutableArray *)allCollections;
- (void)addCollection:(Collection *)collection;
- (Collection *)collectionAtIndex:(NSUInteger)index;
- (void)deleteCurrentCollection;

@end
