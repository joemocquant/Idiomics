//
//  ResizedPanelDownloader.h
//  Idiomics
//
//  Created by Joe Mocquant on 11/24/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AFNetworking.h>

@class Panel;
@protocol ResizedPanelDownloaderDelegate;

@interface ResizedPanelDownloader : AFHTTPRequestOperation

@property (nonatomic, readonly, weak) id<ResizedPanelDownloaderDelegate> delegate;
@property (nonatomic, readonly, strong) NSIndexPath *indexPath;
@property (nonatomic, readonly, strong) Panel *panel;
@property (nonatomic, readonly, strong) UIImage *downloadedImage;

- (id)initWithPanel:(Panel *)panel
        atIndexPath:(NSIndexPath *)indexPath
           delegate:(id<ResizedPanelDownloaderDelegate>)delegate
         urlRequest:(NSURLRequest *)urlRequest;

@end

@protocol ResizedPanelDownloaderDelegate <NSObject>

- (void)resizedPanelDownloaderDidFinish:(ResizedPanelDownloader *)downloader;

@end