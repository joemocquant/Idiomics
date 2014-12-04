//
//  FullSizePanelDownloader.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/26/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Panel;
@protocol FullSizePanelDownloaderDelegate;

@interface FullSizePanelDownloader : NSOperation

@property (nonatomic, readonly, weak) id<FullSizePanelDownloaderDelegate> delegate;
@property (nonatomic, readonly, strong) NSIndexPath *indexPath;
@property (nonatomic, readonly, strong) Panel *panel;

- (id)initWithPanel:(Panel *)record
        atIndexPath:(NSIndexPath *)indexPath
           delegate:(id<FullSizePanelDownloaderDelegate>)delegate;

@end

@protocol FullSizePanelDownloaderDelegate <NSObject>

- (void)fullSizePanelDownloaderDidFinish:(FullSizePanelDownloader *)downloader;

@end