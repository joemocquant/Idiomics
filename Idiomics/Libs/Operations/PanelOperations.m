//
//  PanelOperations.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/24/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "PanelOperations.h"
#import "PanelOperations+CacheManager.h"
#import "Panel.h"
#import "Collection.h"
#import "CollectionStore.h"
#import "UIImage+Tools.h"
#import <UIImageView+AFNetworking.h>

@implementation PanelOperations


#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        resizedPanelDownloadsInProgress = [NSMutableDictionary dictionary];
        resizedPanelDownloadsQueue = [NSOperationQueue new];
        resizedPanelDownloadsQueue.name = @"Resized Panel Downloads Queue";
        resizedPanelDownloadsQueue.maxConcurrentOperationCount = 10;
        
        fullSizePanelDownloadsInProgress = [NSMutableDictionary dictionary];
        fullSizePanelDownloadsQueue = [NSOperationQueue new];
        fullSizePanelDownloadsQueue.name = @"Fullsize Panel Downloads Queue";
        fullSizePanelDownloadsQueue.maxConcurrentOperationCount = 10;
    }
    
    return self;
}


#pragma mark - Private methods

- (void)startResizeOperationForPanel:(Panel *)panel atIndexPath:(NSIndexPath *)indexPath
{
    if (![resizedPanelDownloadsInProgress.allKeys containsObject:indexPath]) {
        
        NSURLRequest *urlRequest = [panel buildUrlRequestForDimensions:panel.thumbSize];
        ResizedPanelDownloader *rpd = [[ResizedPanelDownloader alloc] initWithPanel:panel
                                                                        atIndexPath:indexPath
                                                                           delegate:self
                                                                         urlRequest:urlRequest];
        
        [resizedPanelDownloadsInProgress setObject:rpd forKey:indexPath];
        [resizedPanelDownloadsQueue addOperation:rpd];
    }
}

- (void)startFullSizeOperationsForPanel:(Panel *)panel atIndexPath:(NSIndexPath *)indexPath
{
    if (![fullSizePanelDownloadsInProgress.allKeys containsObject:indexPath]) {
        
        NSURLRequest *urlRequest = [panel buildUrlRequestForDimensions:panel.dimensions];
        FullSizePanelDownloader *fspd = [[FullSizePanelDownloader alloc] initWithPanel:panel
                                                                           atIndexPath:indexPath
                                                                              delegate:self
                                                                            urlRequest:urlRequest];
        
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
    if (!panel.hasThumbSizeImage) {
        NSCachedURLResponse *cachedURLResponse = [PanelOperations getCachedURLResponseForPanel:panel
                                                                                withDesiredRes:panel.thumbSize];
        
        if (cachedURLResponse) {

            NSURLRequest *request = [panel buildUrlRequestForDimensions:panel.thumbSize];
            UIImage *image = [UIImage imageWithData:cachedURLResponse.data];
            
            [[UIImageView sharedImageCache] cacheImage:image forRequest:request];

#ifdef __DEBUG__
            NSLog(@"Accessing cached resource (resizing task %ld)", (long)indexPath.item);
#endif
            
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(reloadItemsAtIndexPaths:)
                                                        withObject:[NSArray arrayWithObject:indexPath]
                                                     waitUntilDone:NO];
            
        } else {
            [self startResizeOperationForPanel:panel atIndexPath:indexPath];
        }
    }
    
    if (!panel.hasFullSizeImage) {
        NSCachedURLResponse *cachedURLResponse = [PanelOperations getCachedURLResponseForPanel:panel
                                                                                withDesiredRes:panel.dimensions];

        if (cachedURLResponse) {

            NSURLRequest *request = [panel buildUrlRequestForDimensions:panel.dimensions];
            UIImage *image = [UIImage imageWithData:cachedURLResponse.data scale:[UIScreen mainScreen].scale];
            [[UIImageView sharedImageCache] cacheImage:image forRequest:request];
            
#ifdef __DEBUG__
            NSLog(@"Accessing cached resource (fullsize task %ld)", (long)indexPath.item);
#endif
            
        } else {
            [self startFullSizeOperationsForPanel:panel atIndexPath:indexPath];
        }
    }
}

- (void)loadPanelsForIndexPaths:(NSArray *)indexPaths
{
    NSSet *visibleItems = [NSSet setWithArray:indexPaths];
    
    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:resizedPanelDownloadsInProgress.allKeys];
    [pendingOperations addObjectsFromArray:fullSizePanelDownloadsInProgress.allKeys];
    
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
        NSLog(@"Canceled panel task(s) %ld", (long)indexPath.item);
#endif
        
    }
    
    for (NSIndexPath *indexPath in toBeStarted) {
        
        Panel *panel = [[CollectionStore sharedStore].currentCollection panelAtIndex:indexPath.item];
        [self startOperationsForPanel:panel atIndexPath:indexPath];
    }
}

- (void)suspendAllOperations
{
    resizedPanelDownloadsQueue.suspended = YES;
    fullSizePanelDownloadsQueue.suspended = YES;
}

- (void)resumeAllOperations
{
    resizedPanelDownloadsQueue.suspended = NO;
    fullSizePanelDownloadsQueue.suspended = NO;
}

- (void)cancelAllOperations
{
    [resizedPanelDownloadsQueue cancelAllOperations];
    [fullSizePanelDownloadsQueue cancelAllOperations];
}


#pragma mark - ResizedPanelDownloaderDelegate

- (void)resizedPanelDownloaderDidFinish:(ResizedPanelDownloader *)downloader
{    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(reloadItemsAtIndexPaths:)
                                                withObject:[NSArray arrayWithObject:downloader.indexPath]
                                             waitUntilDone:NO];
    
    [resizedPanelDownloadsInProgress removeObjectForKey:downloader.indexPath];
    
    
#ifdef __DEBUG__
    NSLog(@"Finished resizing task %ld", (long)downloader.indexPath.item);
#endif
}


#pragma mark - FullSizePanelDownloaderDelegate

- (void)fullSizePanelDownloaderDidFinish:(FullSizePanelDownloader *)downloader
{
    [fullSizePanelDownloadsInProgress removeObjectForKey:downloader.indexPath];
    
#ifdef __DEBUG__
    NSLog(@"Finished fullSize task %ld", (long)downloader.indexPath.item);
#endif
}


@end
