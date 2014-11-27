//
//  ResizedPanelDownloader.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/24/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Panel;
@protocol ResizedPanelDownloaderDelegate;

@interface ResizedPanelDownloader : NSOperation

@property (nonatomic, readonly, weak) id<ResizedPanelDownloaderDelegate> delegate;
@property (nonatomic, readonly, strong) NSIndexPath *indexPath;
@property (nonatomic, readonly, strong) Panel *panel;

- (id)initWithPanel:(Panel *)record
        atIndexPath:(NSIndexPath *)indexPath
           delegate:(id<ResizedPanelDownloaderDelegate>)delegate;

@end

@protocol ResizedPanelDownloaderDelegate <NSObject>

- (void)resizedPanelDownloaderDidFinish:(ResizedPanelDownloader *)downloader;

@end