//
//  LibraryOperations.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/16/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "LibraryOperations.h"
#import "Universe.h"
#import "UniverseStore.h"
#import <UIImageView+AFNetworking.h>

@implementation LibraryOperations


#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        universeCoverDownloadsInProgress = [NSMutableDictionary dictionary];
        universeCoverDownloadsQueue = [NSOperationQueue new];
        universeCoverDownloadsQueue.name = @"Universe Cover Downloads Queue";
    }
    
    return self;
}


#pragma mark - Instance methods

- (void)startOperationsForUniverse:(Universe *)universe atIndexPath:(NSIndexPath *)indexPath
{
    if (![universe hasCoverImage]) {

        NSURLRequest *request = [universe buildUrlRequest];
        NSCachedURLResponse *cachedURLResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
        
        if (cachedURLResponse) {
            
            UIImage *image = [UIImage imageWithData:cachedURLResponse.data scale:[[UIScreen mainScreen] scale]];
            [[UIImageView sharedImageCache] cacheImage:image forRequest:request];
            
#ifdef __DEBUG__
            NSLog(@"Accessing cached resource (cover task %ld)", (long)indexPath.item);
#endif

            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(reloadRowsAtIndexPaths:)
                                                        withObject:[NSArray arrayWithObject:indexPath]
                                                     waitUntilDone:NO];
            
        } else {
        
            if ((![universeCoverDownloadsInProgress.allKeys containsObject:indexPath])
                && (![universe hasCoverImage])) {
            
                NSURLRequest *urlRequest = [universe buildUrlRequest];
                UniverseCoverDownloader *ucd = [[UniverseCoverDownloader alloc] initWithUniverse:universe
                                                                                     atIndexPath:indexPath
                                                                                        delegate:self
                                                                                      urlRequest:urlRequest];
            
                [universeCoverDownloadsInProgress setObject:ucd forKey:indexPath];
                [universeCoverDownloadsQueue addOperation:ucd];
            }
        }
    }
}

- (void)loadPanelsForIndexPaths:(NSArray *)indexPaths
{
    NSSet *visibleItems = [NSSet setWithArray:indexPaths];
    
    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[universeCoverDownloadsInProgress allKeys]];
    
    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
    NSMutableSet *toBeStarted = [visibleItems mutableCopy];
    
    [toBeStarted minusSet:pendingOperations];
    [toBeCancelled minusSet:visibleItems];
    
    for (NSIndexPath *indexPath in toBeCancelled) {
        
        //Should include a check to cancel only those below 60%
        
        UniverseCoverDownloader *pendingUniverseCoverDownload = [universeCoverDownloadsInProgress objectForKey:indexPath];
        [pendingUniverseCoverDownload cancel];
        [universeCoverDownloadsInProgress removeObjectForKey:indexPath];
        
#ifdef __DEBUG__
        NSLog(@"Canceled universe cover task %ld", (long)indexPath.item);
#endif
        
    }
    
    for (NSIndexPath *indexPath in toBeStarted) {
        
        Universe *universe = [[UniverseStore sharedStore] universeAtIndex:indexPath.item];
        [self startOperationsForUniverse:universe atIndexPath:indexPath];
    }
}

- (void)suspendAllOperations
{
    [universeCoverDownloadsQueue setSuspended:YES];
}


- (void)resumeAllOperations
{
    [universeCoverDownloadsQueue setSuspended:NO];
}


- (void)cancelAllOperations
{
    [universeCoverDownloadsQueue cancelAllOperations];
}


#pragma mark - UniverseCoverDownloaderDelegate

- (void)universeCoverDownloaderDidFinish:(UniverseCoverDownloader *)downloader
{
    [self.delegate reloadRowsAtIndexPaths:[NSArray arrayWithObject:downloader.indexPath]];
    [universeCoverDownloadsInProgress removeObjectForKey:downloader.indexPath];
    
#ifdef __DEBUG__
    NSLog(@"Finished universe cover task %ld", (long)downloader.indexPath.item);
#endif
}

@end
