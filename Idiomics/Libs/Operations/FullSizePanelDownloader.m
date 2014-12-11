//
//  FullSizePanelDownloader.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/26/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "FullSizePanelDownloader.h"
#import "Panel.h"

@interface FullSizePanelDownloader ()

@property (nonatomic, readwrite, strong) UIImage *downloadedImage;

@end

@implementation FullSizePanelDownloader


#pragma mark - Lifecycle

- (id)initWithPanel:(Panel *)panel
        atIndexPath:(NSIndexPath *)indexPath
           delegate:(id<FullSizePanelDownloaderDelegate>)delegate
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
    NSLog(@"Starting fullSize task %ld", (long)self.indexPath.item);
#endif
        
    if (self.isCancelled) {
        return;
    }
        
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.panel.imageUrl]];
        
    if (self.isCancelled) {
        imageData = nil;
        return;
    }
        
    if (imageData) {
        self.downloadedImage = [UIImage imageWithData:imageData];
            
    } else {
        self.panel.failed = YES;
    }
        
    imageData = nil;
        
    if (self.isCancelled) {
        return;
    }
    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(fullSizePanelDownloaderDidFinish:)
                                                withObject:self
                                             waitUntilDone:NO];
}

@end
