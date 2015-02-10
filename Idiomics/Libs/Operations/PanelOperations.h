//
//  PanelOperations.h
//  Idiomics
//
//  Created by Joe Mocquant on 11/24/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResizedPanelDownloader.h"
#import "FullSizePanelDownloader.h"

@protocol PanelOperationsDelegate;

@interface PanelOperations : NSObject <ResizedPanelDownloaderDelegate,
                                       FullSizePanelDownloaderDelegate>
{
    NSMutableDictionary *resizedPanelDownloadsInProgress;
    NSOperationQueue *resizedPanelDownloadsQueue;
    
    NSMutableDictionary *fullSizePanelDownloadsInProgress;
    NSOperationQueue *fullSizePanelDownloadsQueue;
}

@property (nonatomic, weak) id<PanelOperationsDelegate> delegate;

- (NSURLRequest *)buildUrlRequestForPanel:(Panel *)panel dimensions:(CGSize)dimensions;
- (void)startOperationsForPanel:(Panel *)panel atIndexPath:(NSIndexPath *)indexPath;
- (void)loadPanelsForIndexPaths:(NSArray *)indexPaths;
- (void)suspendAllOperations;
- (void)resumeAllOperations;
- (void)cancelAllOperations;

@end

@protocol PanelOperationsDelegate <NSObject>

- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths;

@end
