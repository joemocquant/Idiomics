//
//  LibraryOperations.h
//  Idiomics
//
//  Created by Joe Mocquant on 12/16/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionCoverDownloader.h"

@protocol LibraryOperationsDelegate;

@interface LibraryOperations : NSObject <CollectionCoverDownloaderDelegate>
{
    NSMutableDictionary *collectionCoverDownloadsInProgress;
    NSOperationQueue *collectionCoverDownloadsQueue;
}

@property (nonatomic, weak) id<LibraryOperationsDelegate> delegate;

- (void)startOperationsForCollection:(Collection *)collection atIndexPath:(NSIndexPath *)indexPath;
- (void)loadPanelsForIndexPaths:(NSArray *)indexPaths;
- (void)suspendAllOperations;
- (void)resumeAllOperations;
- (void)cancelAllOperations;

@end

@protocol LibraryOperationsDelegate <NSObject>

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths;

@end
