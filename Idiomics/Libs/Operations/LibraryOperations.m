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
#import "ImageStore.h"
#import "Helper.h"
#import "APIClient.h"

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


#pragma mark - Private methods

- (CGSize)getAdaptedSize
{
    CGFloat height;
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    
    if ([Helper isIPhoneDevice]) {
        height = screen.size.height / kRowsiPhonePortrait;
    } else {
        height = MAX(screen.size.height / kRowsiPadPortrait,
                     screen.size.width / kRowsiPadPortrait);
    }
    
    return CGSizeMake(roundf(height * kMashupRatio),
                      roundf(height));
}

- (NSURLRequest *)buildUrlRequestForUniverse:(Universe *)universe
{
    CGSize adaptedSize = [self getAdaptedSize];
    
    NSURL *url = [NSURL URLWithString:[Helper getImageWithUrl:universe.imageUrl size:adaptedSize]];
    
    NSURLRequestCachePolicy cachePolicy = LibraryCachePolicy;
    
    AFNetworkReachabilityStatus networkStatus = [[[APIClient sharedConnection] reachabilityManager] networkReachabilityStatus];
    if ((networkStatus == AFNetworkReachabilityStatusUnknown)
        || (networkStatus == AFNetworkReachabilityStatusNotReachable)) {
        
        cachePolicy = NSURLRequestReturnCacheDataDontLoad;
    }
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:LibraryCachePolicy
                                            timeoutInterval:TimeoutInterval];
    
    return urlRequest;
}


#pragma mark - Instance methods

- (void)startOperationsForUniverse:(Universe *)universe atIndexPath:(NSIndexPath *)indexPath
{
    if (![universe hasCoverImage]) {

        if ((![universeCoverDownloadsInProgress.allKeys containsObject:indexPath])
            && (![universe hasCoverImage])) {
            
            NSURLRequest *urlRequest = [self buildUrlRequestForUniverse:universe];
            UniverseCoverDownloader *ucd = [[UniverseCoverDownloader alloc] initWithUniverse:universe
                                                                                 atIndexPath:indexPath
                                                                                    delegate:self
                                                                                  urlRequest:urlRequest];
            
            [universeCoverDownloadsInProgress setObject:ucd forKey:indexPath];
            [universeCoverDownloadsQueue addOperation:ucd];
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
    [[ImageStore sharedStore] addUniverseImage:downloader.downloadedImage
                                        forKey:downloader.universe.imageUrl];
    
    [self.delegate reloadRowsAtIndexPaths:[NSArray arrayWithObject:downloader.indexPath]];
    [universeCoverDownloadsInProgress removeObjectForKey:downloader.indexPath];
    
#ifdef __DEBUG__
    NSLog(@"Finished universe cover task %ld", (long)downloader.indexPath.item);
#endif
}

@end
