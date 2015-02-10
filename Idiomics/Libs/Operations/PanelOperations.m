//
//  PanelOperations.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/24/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "PanelOperations.h"
#import "PanelOperations+CacheManager.h"
#import "Helper.h"
#import "Panel.h"
#import "ImageStore.h"
#import "Universe.h"
#import "UniverseStore.h"

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
        
        NSURLRequest *urlRequest = [self buildUrlRequestForPanel:panel dimensions:panel.thumbSize];
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
        
        NSURLRequest *urlRequest = [self buildUrlRequestForPanel:panel dimensions:panel.dimensions];
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

- (NSURLRequest *)buildUrlRequestForPanel:(Panel *)panel
                               dimensions:(CGSize)dimensions
{
    NSURL *url = [NSURL URLWithString:[Helper getImageWithUrl:panel.imageUrl size:dimensions]];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:PanelCachePolicy
                                            timeoutInterval:TimeoutInterval];
    
    return urlRequest;
}

- (void)startOperationsForPanel:(Panel *)panel atIndexPath:(NSIndexPath *)indexPath
{
    if (!panel.hasThumbImage) {
        NSCachedURLResponse *cache = [self getCachedURLResponseForPanel:panel
                                                         withDesiredRes:panel.thumbSize];
        
        if (cache) {
            
#ifdef __DEBUG__
            NSLog(@"Accessing cached resource (resizing task %ld)", (long)indexPath.item);
#endif
            
            [[ImageStore sharedStore] addPanelThumbImage:[UIImage imageWithData:cache.data]
                                                  forKey:panel.imageUrl];
            
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(reloadItemsAtIndexPaths:)
                                                        withObject:[NSArray arrayWithObject:indexPath]
                                                     waitUntilDone:NO];
            
        } else {
            [self startResizeOperationForPanel:panel atIndexPath:indexPath];
        }
    }
    
    if (!panel.hasFullSizeImage) {
        NSCachedURLResponse *cache = [self getCachedURLResponseForPanel:panel
                                                         withDesiredRes:panel.dimensions];

        if (cache) {

#ifdef __DEBUG__
            NSLog(@"Accessing cached resource (fullsize task %ld)", (long)indexPath.item);
#endif
            
            [[ImageStore sharedStore] addPanelFullSizeImage:[UIImage imageWithData:cache.data
                                                                             scale:[[UIScreen mainScreen] scale]]
                                                     forKey:panel.imageUrl];
        } else {
            [self startFullSizeOperationsForPanel:panel atIndexPath:indexPath];
        }
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
        NSLog(@"Canceled panel task(s) %ld", (long)indexPath.item);
#endif
        
    }
    
    for (NSIndexPath *indexPath in toBeStarted) {
        
        Panel *panel = [[[UniverseStore sharedStore] currentUniverse] panelAtIndex:indexPath.item];
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
    [[ImageStore sharedStore] addPanelThumbImage:downloader.downloadedImage
                                          forKey:downloader.panel.imageUrl];
    
    [self.delegate reloadItemsAtIndexPaths:[NSArray arrayWithObject:downloader.indexPath]];
    [resizedPanelDownloadsInProgress removeObjectForKey:downloader.indexPath];
    
#ifdef __DEBUG__
    NSLog(@"Finished resizing task %ld", (long)downloader.indexPath.item);
#endif
}


#pragma mark - FullSizePanelDownloaderDelegate

- (void)fullSizePanelDownloaderDidFinish:(FullSizePanelDownloader *)downloader
{
    [[ImageStore sharedStore] addPanelFullSizeImage:downloader.downloadedImage
                                             forKey:downloader.panel.imageUrl];
    
    [fullSizePanelDownloadsInProgress removeObjectForKey:downloader.indexPath];
    
#ifdef __DEBUG__
    NSLog(@"Finished fullSize task %ld", (long)downloader.indexPath.item);
#endif
}


@end
