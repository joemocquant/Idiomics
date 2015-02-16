//
//  LibraryOperations.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/16/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "LibraryOperations.h"
#import "Collection.h"
#import "CollectionStore.h"
#import <UIImageView+AFNetworking.h>

@implementation LibraryOperations


#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        collectionCoverDownloadsInProgress = [NSMutableDictionary dictionary];
        collectionCoverDownloadsQueue = [NSOperationQueue new];
        collectionCoverDownloadsQueue.name = @"Collection Cover Downloads Queue";
    }
    
    return self;
}


#pragma mark - Instance methods

- (void)startOperationsForCollection:(Collection *)collection atIndexPath:(NSIndexPath *)indexPath
{
    if (![collection hasCoverImage]) {

        NSURLRequest *request = [collection buildUrlRequest];
        NSCachedURLResponse *cachedURLResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
        
        if (cachedURLResponse) {
            
            UIImage *image = [UIImage imageWithData:cachedURLResponse.data scale:[UIScreen mainScreen].scale];
            [[UIImageView sharedImageCache] cacheImage:image forRequest:request];
            
#ifdef __DEBUG__
            NSLog(@"Accessing cached resource (cover task %ld)", (long)indexPath.item);
#endif

            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(reloadRowsAtIndexPaths:)
                                                        withObject:[NSArray arrayWithObject:indexPath]
                                                     waitUntilDone:NO];
            
        } else {
        
            if ((![collectionCoverDownloadsInProgress.allKeys containsObject:indexPath])
                && (!collection.hasCoverImage)) {
            
                NSURLRequest *urlRequest = [collection buildUrlRequest];
                CollectionCoverDownloader *ucd = [[CollectionCoverDownloader alloc] initWithCollection:collection
                                                                                         atIndexPath:indexPath
                                                                                            delegate:self
                                                                                          urlRequest:urlRequest];
            
                [collectionCoverDownloadsInProgress setObject:ucd forKey:indexPath];
                [collectionCoverDownloadsQueue addOperation:ucd];
            }
        }
    }
}

- (void)loadPanelsForIndexPaths:(NSArray *)indexPaths
{
    NSSet *visibleItems = [NSSet setWithArray:indexPaths];
    
    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[collectionCoverDownloadsInProgress allKeys]];
    
    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
    NSMutableSet *toBeStarted = [visibleItems mutableCopy];
    
    [toBeStarted minusSet:pendingOperations];
    [toBeCancelled minusSet:visibleItems];
    
    for (NSIndexPath *indexPath in toBeCancelled) {
        
        //Should include a check to cancel only those below 60%
        
        CollectionCoverDownloader *pendingCollectionCoverDownload = [collectionCoverDownloadsInProgress objectForKey:indexPath];
        [pendingCollectionCoverDownload cancel];
        [collectionCoverDownloadsInProgress removeObjectForKey:indexPath];
        
#ifdef __DEBUG__
        NSLog(@"Canceled collection cover task %ld", (long)indexPath.item);
#endif
        
    }
    
    for (NSIndexPath *indexPath in toBeStarted) {
        
        Collection *collection = [[CollectionStore sharedStore] collectionAtIndex:indexPath.item];
        [self startOperationsForCollection:collection atIndexPath:indexPath];
    }
}

- (void)suspendAllOperations
{
    collectionCoverDownloadsQueue.suspended = YES;
}


- (void)resumeAllOperations
{
    collectionCoverDownloadsQueue.suspended = NO;
}


- (void)cancelAllOperations
{
    [collectionCoverDownloadsQueue cancelAllOperations];
}


#pragma mark - CollectionCoverDownloaderDelegate

- (void)collectionCoverDownloaderDidFinish:(CollectionCoverDownloader *)downloader
{
    [self.delegate reloadRowsAtIndexPaths:[NSArray arrayWithObject:downloader.indexPath]];
    [collectionCoverDownloadsInProgress removeObjectForKey:downloader.indexPath];
    
#ifdef __DEBUG__
    NSLog(@"Finished collection cover task %ld", (long)downloader.indexPath.item);
#endif
}

@end
