//
//  FullSizePanelDownloader.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/26/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "FullSizePanelDownloader.h"
#import <extobjc.h>
#import <GAI.h>
#import <GAIDictionaryBuilder.h>

@interface FullSizePanelDownloader ()

@property (nonatomic, readwrite, strong) UIImage *downloadedImage;

@end

@implementation FullSizePanelDownloader


#pragma mark - Lifecycle

- (id)initWithPanel:(Panel *)panel
        atIndexPath:(NSIndexPath *)indexPath
           delegate:(id<FullSizePanelDownloaderDelegate>)delegate
         urlRequest:(NSURLRequest *)urlRequest
{
    self = [super initWithRequest:urlRequest];
    
    if (self) {
        _delegate = delegate;
        _indexPath = indexPath;
        _panel = panel;
        
        [self setResponseSerializer:[AFImageResponseSerializer serializer]];
        
#ifdef __DEBUG__
        NSLog(@"Starting fullSize task %ld", (long)self.indexPath.item);
#endif
        
        NSDate *trackingIntervalStart = [NSDate date];
        
        @weakify(self)
        [self setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            @strongify(self)
            
            self.downloadedImage = responseObject;
            
            NSInteger elapsed = [trackingIntervalStart timeIntervalSinceNow] * -1 * 1000;
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:@"ui_loading_time"
                                                                 interval:@(elapsed)
                                                                     name:@"fullsize_panel"
                                                                    label:nil] build]];
            
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(fullSizePanelDownloaderDidFinish:)
                                                        withObject:self
                                                     waitUntilDone:NO];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];

    }
    
    return self;
}

@end
