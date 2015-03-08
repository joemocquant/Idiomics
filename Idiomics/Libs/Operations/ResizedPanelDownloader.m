//
//  ResizedPanelDownloader.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/24/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "ResizedPanelDownloader.h"
#import "Panel.h"
#import "UIImage+Tools.h"
#import <extobjc.h>
#import <UIImageView+AFNetworking.h>
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
            
            self.downloadedImage = (UIImage *)responseObject;
            
            [[UIImageView sharedImageCache] cacheImage:self.downloadedImage forRequest:urlRequest];
            
            NSInteger elapsed = trackingIntervalStart.timeIntervalSinceNow * -1 * 1000;
            id tracker = [GAI sharedInstance].defaultTracker;
            [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:@"ui_loading_time"
                                                                 interval:@(elapsed)
                                                                     name:@"resized_panel"
                                                                    label:panel.panelId] build]];
            
            [self.delegate resizedPanelDownloaderDidFinish:self];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    
    return self;
}


#pragma mark - NSURLConnectionDataDelegate

//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
//                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
//{
//    return nil;
//}

@end
