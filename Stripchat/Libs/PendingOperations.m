//
//  PendingOperations.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/24/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "PendingOperations.h"
#import "Panel.h"
#import "PanelStore.h"

@implementation PendingOperations


#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        resizedPanelDownloadsInProgress = [NSMutableDictionary dictionary];
        resizedPanelDownloadsQueue = [NSOperationQueue new];
        resizedPanelDownloadsQueue.name = @"Resized Panel Downloads Queue";
        
        fullSizePanelDownloadsInProgress = [NSMutableDictionary dictionary];
        fullSizePanelDownloadsQueue = [NSOperationQueue new];
        fullSizePanelDownloadsQueue.name = @"Fullsize Panel Downloads Queue";
    }
    
    return self;
}


#pragma mark - Private methods

- (void)startResizeOperationForPanel:(Panel *)panel atIndexPath:(NSIndexPath *)indexPath
{
    if (![resizedPanelDownloadsInProgress.allKeys containsObject:indexPath]) {
        
        ResizedPanelDownloader *rpd = [[ResizedPanelDownloader alloc] initWithPanel:panel
                                                                        atIndexPath:indexPath
                                                                           delegate:self];
        
        [resizedPanelDownloadsInProgress setObject:rpd forKey:indexPath];
        [resizedPanelDownloadsQueue addOperation:rpd];
    }
}

- (void)startFullSizeOperationsForPanel:(Panel *)panel atIndexPath:(NSIndexPath *)indexPath
{
    if (![fullSizePanelDownloadsInProgress.allKeys containsObject:indexPath]) {
        
        FullSizePanelDownloader *fspd = [[FullSizePanelDownloader alloc] initWithPanel:panel
                                                                           atIndexPath:indexPath
                                                                              delegate:self];
        
        ResizedPanelDownloader *rpd = [resizedPanelDownloadsInProgress objectForKey:indexPath];
        if (rpd) {
            [fspd addDependency:rpd];
        }
        
        [fullSizePanelDownloadsInProgress setObject:fspd forKey:indexPath];
        [fullSizePanelDownloadsQueue addOperation:fspd];
    }
}


#pragma mark - Instance methods

- (void)startOperationsForPanel:(Panel *)panel atIndexPath:(NSIndexPath *)indexPath
{
    if (!panel.hasThumbImage) {
        [self startResizeOperationForPanel:panel atIndexPath:indexPath];
    }
    
    if (!panel.hasFullSizeImage) {
        [self startFullSizeOperationsForPanel:panel atIndexPath:indexPath];
    }
}

- (void)loadPanelsForIndexPaths:(NSArray *)indexPaths
{
    NSSet *visibleItems = [NSSet setWithArray:indexPaths];
    
    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[resizedPanelDownloadsInProgress allKeys]];
    [pendingOperations addObjectsFromArray:[fullSizePanelDownloadsInProgress allKeys]];
    
    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
    NSMutableSet *toBeStarted = [visibleItems mutableCopy];
    
    [toBeStarted minusSet:pendingOperations];
    [toBeCancelled minusSet:visibleItems];
    
    for (NSIndexPath *indexPath in toBeCancelled) {
        
        //Should include a check to cancel only those below 60%
        
        ResizedPanelDownloader *pendingResizingDownload = [resizedPanelDownloadsInProgress objectForKey:indexPath];
        [pendingResizingDownload cancel];
        [resizedPanelDownloadsInProgress removeObjectForKey:indexPath];
        
        FullSizePanelDownloader *pendingFullSizeDownload = [fullSizePanelDownloadsInProgress objectForKey:indexPath];
        [pendingFullSizeDownload cancel];
        [fullSizePanelDownloadsInProgress removeObjectForKey:indexPath];
        
#ifdef __DEBUG__
        NSLog(@"Canceled task %ld", (long)indexPath.item);
#endif
        
    }
    
    for (NSIndexPath *indexPath in toBeStarted) {
        
        Panel *panel = [[PanelStore sharedStore] panelAtIndex:indexPath.item];
        [self startOperationsForPanel:panel atIndexPath:indexPath];
    }
}

- (void)suspendAllOperations
{
    [resizedPanelDownloadsQueue setSuspended:YES];
    [fullSizePanelDownloadsQueue setSuspended:YES];
}


- (void)resumeAllOperations
{
    [resizedPanelDownloadsQueue setSuspended:NO];
    [fullSizePanelDownloadsQueue setSuspended:NO];
}


- (void)cancelAllOperations
{
    [resizedPanelDownloadsQueue cancelAllOperations];
    [fullSizePanelDownloadsQueue cancelAllOperations];
}


#pragma mark - ResizedPanelDownloaderDelegate

- (void)resizedPanelDownloaderDidFinish:(ResizedPanelDownloader *)downloader
{
    [self.delegate reloadItemsAtIndexPaths:[NSArray arrayWithObject:downloader.indexPath]];
    //[self.pendingOperations.resizedPanelDownloadsInProgress removeObjectForKey:downloader.indexPath];
    
#ifdef __DEBUG__
    NSLog(@"Finished resizing task %ld", (long)downloader.indexPath.item);
#endif
}


#pragma mark - FullSizePanelDownloaderDelegate

- (void)fullSizePanelDownloaderDidFinish:(FullSizePanelDownloader *)downloader
{
    //[self.pendingOperations.fullSizePanelDownloadsInProgress removeObjectForKey:downloader.indexPath];
    
#ifdef __DEBUG__
    NSLog(@"Finished fullSize task %ld", (long)downloader.indexPath.item);
#endif
}


@end
