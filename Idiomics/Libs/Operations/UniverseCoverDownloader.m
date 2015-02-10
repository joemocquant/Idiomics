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
#import <extobjc.h>
#import <GAI.h>
#import <GAIDictionaryBuilder.h>

@interface UniverseCoverDownloader ()

@property (nonatomic, readwrite, strong) UIImage *downloadedImage;

@end

@implementation UniverseCoverDownloader


#pragma mark - Class methods

+ (NSURLRequest *)buildUrlRequestForUniverse:(Universe *)universe
{
    CGSize adaptedSize = [self getAdaptedSize];
    
    NSURL *url = [NSURL URLWithString:[Helper getImageWithUrl:universe.imageUrl size:adaptedSize]];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:LibraryCachePolicy
                                            timeoutInterval:TimeoutInterval];
    
    return urlRequest;
}

+ (CGSize)getAdaptedSize
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


#pragma mark - Lifecycle

- (id)initWithUniverse:(Universe *)universe
           atIndexPath:(NSIndexPath *)indexPath
              delegate:(id<UniverseCoverDownloaderDelegate>)delegate
{
    self = [super initWithRequest:[UniverseCoverDownloader buildUrlRequestForUniverse:universe]];
    
    if (self) {
        _delegate = delegate;
        _indexPath = indexPath;
        _universe = universe;
        
        [self setResponseSerializer:[AFImageResponseSerializer serializer]];
        
#ifdef __DEBUG__
        NSLog(@"Starting universe cover task %ld", (long)self.indexPath.item);
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
                                                                     name:@"universe_cover"
                                                                    label:nil] build]];
            
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(universeCoverDownloaderDidFinish:)
                                                        withObject:self
                                                     waitUntilDone:NO];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    
    return self;
}

@end
