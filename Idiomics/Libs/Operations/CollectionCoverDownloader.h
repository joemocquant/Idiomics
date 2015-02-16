//
//  CollectionCoverDownloader.h
//  Idiomics
//
//  Created by Joe Mocquant on 12/16/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@class Collection;
@protocol CollectionCoverDownloaderDelegate;

@interface CollectionCoverDownloader : AFHTTPRequestOperation

@property (nonatomic, readonly, weak) id<CollectionCoverDownloaderDelegate> delegate;
@property (nonatomic, readonly, strong) NSIndexPath *indexPath;
@property (nonatomic, readonly, strong) Collection *collection;
@property (nonatomic, readonly, strong) UIImage *downloadedImage;

- (id)initWithCollection:(Collection *)record
             atIndexPath:(NSIndexPath *)indexPath
                delegate:(id<CollectionCoverDownloaderDelegate>)delegate
              urlRequest:(NSURLRequest *)urlRequest;

@end

@protocol CollectionCoverDownloaderDelegate <NSObject>

- (void)collectionCoverDownloaderDidFinish:(CollectionCoverDownloader *)downloader;

@end