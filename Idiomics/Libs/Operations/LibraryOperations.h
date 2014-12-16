//
//  LibraryOperations.h
//  Idiomics
//
//  Created by Joe Mocquant on 12/16/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UniverseCoverDownloader.h"

@protocol LibraryOperationsDelegate;

@interface LibraryOperations : NSObject <UniverseCoverDownloaderDelegate>
{
    NSMutableDictionary *universeCoverDownloadsInProgress;
    NSOperationQueue *universeCoverDownloadsQueue;
}

@property (nonatomic, weak) id<LibraryOperationsDelegate> delegate;

- (void)startOperationsForUniverse:(Universe *)universe atIndexPath:(NSIndexPath *)indexPath;
- (void)loadPanelsForIndexPaths:(NSArray *)indexPaths;
- (void)suspendAllOperations;
- (void)resumeAllOperations;
- (void)cancelAllOperations;

@end

@protocol LibraryOperationsDelegate <NSObject>

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths;

@end
