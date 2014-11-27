//
//  ResizedPanelDownloader.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/24/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "ResizedPanelDownloader.h"
#import "Panel.h"
#import "PanelImageStore.h"
#import "Helper.h"

@implementation ResizedPanelDownloader


#pragma mark - Lifecycle

- (id)initWithPanel:(Panel *)panel
        atIndexPath:(NSIndexPath *)indexPath
           delegate:(id<ResizedPanelDownloaderDelegate>)delegate
{
    self = [super init];
    
    if (self) {
        _delegate = delegate;
        _indexPath = indexPath;
        _panel = panel;
    }
    
    return self;
}


#pragma mark - Downloading resized panel

- (void)main
{
    
#ifdef __DEBUG__
    NSLog(@"Starting resizing task %ld", (long)self.indexPath.item);
#endif
    
    @autoreleasepool {

        if (self.isCancelled) {
            return;
        }

        CGSize adaptedSize = [self getAdaptedSize];
        NSURL *url = [NSURL URLWithString:[Helper getImageWithUrl:self.panel.imageUrl
                                                            witdh:adaptedSize.width
                                                           height:adaptedSize.height]];

        NSData *imageData = [[NSData alloc] initWithContentsOfURL:url];
        
        if (self.isCancelled) {
            imageData = nil;
            return;
        }
        
        if (imageData) {
            UIImage *downloadedImage = [UIImage imageWithData:imageData];
            [[PanelImageStore sharedStore] addPanelThumbImage:downloadedImage forKey:self.panel.imageUrl];
            
        } else {
            self.panel.failed = YES;
        }
        
        imageData = nil;
        
        if (self.isCancelled) {
            return;
        }
        
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(resizedPanelDownloaderDidFinish:)
                                                    withObject:self
                                                 waitUntilDone:NO];
    }
}

- (CGSize)getAdaptedSize
{
    CGFloat scaleWidth = self.panel.dimensions.width / self.panel.thumbSize.width;
    CGFloat scaleHeight = self.panel.dimensions.height / self.panel.thumbSize.height;
    
    CGFloat scale = MIN(scaleWidth, scaleHeight);
    
    return CGSizeMake(roundf(self.panel.dimensions.width / scale),
                      roundf(self.panel.dimensions.height / scale));
}

@end
