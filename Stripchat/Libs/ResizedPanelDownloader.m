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


#pragma mark - Life Cycle

- (id)initWithPanel:(Panel *)panel
        atIndexPath:(NSIndexPath *)indexPath
           delegate:(id<ResizedPanelDownloaderDelegate>)delegate
{
    self = [super init];
    
    if (self) {
        _delegate = delegate;
        _indexPath = indexPath;
        _panel = panel;
        minSize = [Helper getMinPanelSize];
    }
    
    return self;
}


#pragma mark - Downloading resized panel

- (void)main
{
    @autoreleasepool {

        if (self.isCancelled) {
            return;
        }
        
        //Should include resized optimizisation here (based on network connectivity)

//        CGSize adaptedSize = [self getAdaptedSize];
//        NSURL *url = [NSURL URLWithString:[Helper getImageWithUrl:self.panel.imageUrl
//                                                            witdh:adaptedSize.width
//                                                           height:adaptedSize.height]];
        
//        NSData *imageData = [[NSData alloc] initWithContentsOfURL:url];
        
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.panel.imageUrl]];
        
        if (self.isCancelled) {
            imageData = nil;
            return;
        }
        
        if (imageData) {
            UIImage *downloadedImage = [UIImage imageWithData:imageData];
            [[PanelImageStore sharedStore] addPanelImage:downloadedImage forKey:self.panel.imageUrl];
            
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
    return CGSizeZero;
}

@end
