//
//  PendingOperations.h
//  Idiomics
//
//  Created by Joe Mocquant on 11/24/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResizedPanelDownloader.h"
#import "FullSizePanelDownloader.h"

@protocol PendingOperationsDelegate;

@interface PendingOperations : NSObject <ResizedPanelDownloaderDelegate,
                                         FullSizePanelDownloaderDelegate>
{
    NSMutableDictionary *resizedPanelDownloadsInProgress;
    NSMutableArray *resizedPanelDownloadsFinished;
    NSOperationQueue *resizedPanelDownloadsQueue;
    
    NSMutableDictionary *fullSizePanelDownloadsInProgress;
    NSMutableArray *fullSizePanelDownloadsFinished;
    NSOperationQueue *fullSizePanelDownloadsQueue;
}

@property (nonatomic, weak) id<PendingOperationsDelegate> delegate;

- (void)startOperationsForPanel:(Panel *)panel atIndexPath:(NSIndexPath *)indexPath;
- (void)loadPanelsForIndexPaths:(NSArray *)indexPaths;
- (void)suspendAllOperations;
- (void)resumeAllOperations;
- (void)cancelAllOperations;

@end

@protocol PendingOperationsDelegate <NSObject>

- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths;

@end
