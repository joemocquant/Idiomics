//
//  UniverseStore.h
//  Idiomics
//
//  Created by Joe Mocquant on 12/15/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Universe;

@interface UniverseStore : NSObject
{
    NSMutableArray *allUniverses;
}

@property (nonatomic, strong) Universe *currentUniverse;

+ (instancetype)sharedStore;
- (NSMutableArray *)allUniverses;
- (void)addUniverse:(Universe *)universe;
- (Universe *)universeAtIndex:(NSUInteger)index;
- (void)deleteCurrentUniverse;

@end
