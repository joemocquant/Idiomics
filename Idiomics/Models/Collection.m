//
//  Collection.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/14/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "Collection.h"
#import "ColorTransformer.h"
#import "Panel.h"
#import "Helper.h"
#import "APIClient.h"
#import <UIImageView+AFNetworking.h>
#import <AFNetworking.h>

@implementation Collection


#pragma mark - Lifecycle

+ (void)initialize
{
    if (self == Collection.class) {
        ColorTransformer *transformer = [ColorTransformer new];
        [NSValueTransformer setValueTransformer:transformer forName:ColorTransformerName];
    }
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        allPanels = [NSMutableArray array];
    }
    
    return self;
}


#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"collectionId": @"id",
             @"imageUrl": @"mashup_url",
             @"averageColor": @"avg_color",
             @"iconUrl": @"icon_url"
             };
}

+ (NSValueTransformer *)averageColorJSONTransformer
{
    return [MTLValueTransformer valueTransformerForName:ColorTransformerName];
}


#pragma mark - Private methods

- (CGSize)getAdaptedSize
{
    CGFloat height;
    
    CGRect screen = [UIScreen mainScreen].bounds;
    
    if ([Helper isIPhoneDevice]) {
        height = screen.size.height / kRowsiPhonePortrait;
    } else {
        height = MAX(screen.size.height / kRowsiPadPortrait,
                     screen.size.width / kRowsiPadPortrait);
    }
    
    return CGSizeMake(roundf(height * kMashupRatio),
                      roundf(height));
}


#pragma mark - Instance methods

- (NSURLRequest *)buildUrlRequest
{
    CGSize adaptedSize = [self getAdaptedSize];
    
    NSURL *url = [NSURL URLWithString:[Helper getImageWithUrl:self.imageUrl size:adaptedSize]];
    
    NSURLRequestCachePolicy cachePolicy = LibraryCachePolicy;
    
    AFNetworkReachabilityStatus networkStatus = [APIClient sharedConnection].reachabilityManager.networkReachabilityStatus;
    if ((networkStatus == AFNetworkReachabilityStatusUnknown)
        || (networkStatus == AFNetworkReachabilityStatusNotReachable)) {
        
        cachePolicy = NSURLRequestReturnCacheDataDontLoad;
    }
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:LibraryCachePolicy
                                            timeoutInterval:TimeoutInterval];
    
    return urlRequest;
}

- (NSMutableArray *)allPanels
{
    if (!allPanels) {
        allPanels = [NSMutableArray array];
    }
    
    return allPanels;
}

- (void)addPanel:(Panel *)panel
{
    [self.allPanels addObject:panel];
}

- (Panel *)panelAtIndex:(NSUInteger)index
{
    return [self.allPanels objectAtIndex:index];
}

- (void)deleteAllPanels
{
    [self.allPanels removeAllObjects];
}

- (UIImage *)coverImage
{
    NSURLRequest *urlRequest = [self buildUrlRequest];
    UIImage *image = [[UIImageView sharedImageCache] cachedImageForRequest:urlRequest];
    
    return image;
}


#pragma mark - Getters/setters

- (BOOL)isFailed
{
    return _failed;
}

- (BOOL)hasCoverImage
{
    NSURLRequest *urlRequest = [self buildUrlRequest];
    UIImage *image = [[UIImageView sharedImageCache] cachedImageForRequest:urlRequest];
    
    return (image != nil);
}

@end
