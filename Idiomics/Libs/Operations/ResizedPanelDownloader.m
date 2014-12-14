//
//  ResizedPanelDownloader.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/24/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "ResizedPanelDownloader.h"
#import "Panel.h"
#import "Helper.h"
#import <GAI.h>
#import <GAIDictionaryBuilder.h>

@interface ResizedPanelDownloader ()

@property (nonatomic, readwrite, strong) UIImage *downloadedImage;

@end

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

    NSDate *trackingIntervalStart = [NSDate date];
    
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
        self.downloadedImage = [UIImage imageWithData:imageData];
            
    } else {
        self.panel.failed = YES;
    }
        
    imageData = nil;
        
    if (self.isCancelled) {
        return;
    }
    
    NSInteger elapsed = [trackingIntervalStart timeIntervalSinceNow] * -1 * 1000;
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:@"ui_loading_time"
                                                         interval:@(elapsed)
                                                             name:@"resized_panel"
                                                            label:nil] build]];
    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(resizedPanelDownloaderDidFinish:)
                                                withObject:self
                                             waitUntilDone:NO];
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
