//
//  UniverseCoverDownloader.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/16/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "UniverseCoverDownloader.h"
#import "Universe.h"
#import "Helper.h"
#import <GAI.h>
#import <GAIDictionaryBuilder.h>

@interface UniverseCoverDownloader ()

@property (nonatomic, readwrite, strong) UIImage *downloadedImage;

@end

@implementation UniverseCoverDownloader


#pragma mark - Lifecycle

- (id)initWithUniverse:(Universe *)universe
           atIndexPath:(NSIndexPath *)indexPath
              delegate:(id<UniverseCoverDownloaderDelegate>)delegate
{
    self = [super init];
    
    if (self) {
        _delegate = delegate;
        _indexPath = indexPath;
        _universe = universe;
    }
    
    return self;
}


#pragma mark - Downloading resized panel

- (void)main
{
    
#ifdef __DEBUG__
    NSLog(@"Starting universe cover task %ld", (long)self.indexPath.item);
#endif
    
    NSDate *trackingIntervalStart = [NSDate date];
    
    if (self.isCancelled) {
        return;
    }
    
    CGSize adaptedSize = [self getAdaptedSize];
    NSURL *url = [NSURL URLWithString:[Helper getImageWithUrl:self.universe.imageUrl
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
        self.universe.failed = YES;
    }
    
    imageData = nil;
    
    if (self.isCancelled) {
        return;
    }
    
    NSInteger elapsed = [trackingIntervalStart timeIntervalSinceNow] * -1 * 1000;
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:@"ui_loading_time"
                                                         interval:@(elapsed)
                                                             name:@"universe_cover"
                                                            label:nil] build]];
    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(universeCoverDownloaderDidFinish:)
                                                withObject:self
                                             waitUntilDone:NO];
}

- (CGSize)getAdaptedSize
{
    CGFloat height;
     
    CGRect screen = [[UIScreen mainScreen] bounds];
     
    if ([Helper isIPhoneDevice]) {
        height = screen.size.height / kRowsiPhonePortrait;
    } else {
        height = MAX(screen.size.height / kRowsiPadPortrait,
                     screen.size.width / kRowsiPadPortrait);
    }
    
    return CGSizeMake(roundf(height * kMashupRatio),
                      roundf(height));
}

@end















