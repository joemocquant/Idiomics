//
//  UniverseCoverDownloader.h
//  Idiomics
//
//  Created by Joe Mocquant on 12/16/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@class Universe;
@protocol UniverseCoverDownloaderDelegate;

@interface UniverseCoverDownloader : AFHTTPRequestOperation

@property (nonatomic, readonly, weak) id<UniverseCoverDownloaderDelegate> delegate;
@property (nonatomic, readonly, strong) NSIndexPath *indexPath;
@property (nonatomic, readonly, strong) Universe *universe;
@property (nonatomic, readonly, strong) UIImage *downloadedImage;

- (id)initWithUniverse:(Universe *)record
           atIndexPath:(NSIndexPath *)indexPath
              delegate:(id<UniverseCoverDownloaderDelegate>)delegate;

@end

@protocol UniverseCoverDownloaderDelegate <NSObject>

- (void)universeCoverDownloaderDidFinish:(UniverseCoverDownloader *)downloader;

@end