//
//  CollectionCoverDownloader.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/16/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "CollectionCoverDownloader.h"
#import "Collection.h"
#import "APIClient.h"
#import <extobjc.h>
#import <UIImageView+AFNetworking.h>
#import <GAI.h>
#import <GAIDictionaryBuilder.h>

@interface CollectionCoverDownloader ()

@property (nonatomic, readwrite, strong) UIImage *downloadedImage;

@end

@implementation CollectionCoverDownloader


#pragma mark - Lifecycle

- (id)initWithCollection:(Collection *)collection
             atIndexPath:(NSIndexPath *)indexPath
                delegate:(id<CollectionCoverDownloaderDelegate>)delegate
              urlRequest:(NSURLRequest *)urlRequest
{
    self = [super initWithRequest:urlRequest];
    
    if (self) {
        _delegate = delegate;
        _indexPath = indexPath;
        _collection = collection;
        
        [self setResponseSerializer:[AFImageResponseSerializer serializer]];
        
#ifdef __DEBUG__
        NSLog(@"Starting collection cover task %ld", (long)self.indexPath.item);
#endif
        
        NSDate *trackingIntervalStart = [NSDate date];

        @weakify(self)
        [self setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            @strongify(self)
            
            self.downloadedImage = responseObject;
            [[UIImageView sharedImageCache] cacheImage:responseObject forRequest:urlRequest];
            
            NSInteger elapsed = trackingIntervalStart.timeIntervalSinceNow * -1 * 1000;
            id tracker = [GAI sharedInstance].defaultTracker;
            [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:@"ui_loading_time"
                                                                 interval:@(elapsed)
                                                                     name:@"collection_cover"
                                                                    label:collection.collectionId] build]];
            
            [self.delegate collectionCoverDownloaderDidFinish:self];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    
    return self;
}


#pragma mark - NSURLConnectionDataDelegate

//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
//                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
//{
//    return nil;
//}

@end
