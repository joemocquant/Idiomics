//
//  ResizedPanelDownloader.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/24/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "ResizedPanelDownloader.h"
#import <extobjc.h>
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
         urlRequest:(NSURLRequest *)urlRequest
{
    self = [super initWithRequest:urlRequest];
    
    if (self) {
        _delegate = delegate;
        _indexPath = indexPath;
        _panel = panel;
        
        [self setResponseSerializer:[AFImageResponseSerializer serializer]];
        
#ifdef __DEBUG__
        NSLog(@"Starting resizing task %ld", (long)self.indexPath.item);
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
                                                                     name:@"resized_panel"
                                                                    label:nil] build]];
            
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(resizedPanelDownloaderDidFinish:)
                                                        withObject:self
                                                     waitUntilDone:NO];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    
    return self;
}

@end
