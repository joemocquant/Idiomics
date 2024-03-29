//
//  FullSizePanelDownloader.h
//  Idiomics
//
//  Created by Joe Mocquant on 11/26/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@class Panel;
@protocol FullSizePanelDownloaderDelegate;

@interface FullSizePanelDownloader : AFHTTPRequestOperation

@property (nonatomic, readonly, weak) id<FullSizePanelDownloaderDelegate> delegate;
@property (nonatomic, readonly, strong) NSIndexPath *indexPath;
@property (nonatomic, readonly, strong) Panel *panel;
@property (nonatomic, readonly, strong) UIImage *downloadedImage;

- (id)initWithPanel:(Panel *)panel
        atIndexPath:(NSIndexPath *)indexPath
           delegate:(id<FullSizePanelDownloaderDelegate>)delegate
         urlRequest:(NSURLRequest *)urlRequest;

@end

@protocol FullSizePanelDownloaderDelegate <NSObject>

- (void)fullSizePanelDownloaderDidFinish:(FullSizePanelDownloader *)downloader;

@end