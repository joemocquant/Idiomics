//
//  Panel.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "Panel.h"
#import "Balloon.h"
#import "Helper.h"
#import "APIClient.h"
#import <UIImageView+AFNetworking.h>
#import <AFNetworking.h>

@interface Panel ()

@property (nonatomic, copy, readwrite) NSString *panelId;
@property (nonatomic, assign, readwrite) CGSize dimensions;
@property (nonatomic, copy, readwrite) NSString *imageUrl;
@property (nonatomic, copy, readwrite) NSArray *balloons;
@property (nonatomic, copy, readwrite) UIColor *averageColor;

@end

@implementation Panel


#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"panelId": @"_id",
             @"dimensions": @"dimensions",
             @"imageUrl": @"image_url",
             @"balloons": @"balloons",
             @"averageColor": @"avg_color"
             };
}

+ (NSValueTransformer *)dimensionsJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSArray *dimensions) {
        return [NSValue valueWithCGSize:CGSizeMake(roundf([dimensions[0] floatValue] / [[UIScreen mainScreen] scale]),
                                                   roundf([dimensions[1] floatValue] / [[UIScreen mainScreen] scale]))];
        
    } reverseBlock:^id(NSValue *dimensions) {
        
        CGSize size = [dimensions CGSizeValue];
        return @[@(size.width * [[UIScreen mainScreen] scale]),
                 @(size.height * [[UIScreen mainScreen] scale])];
    }];
}

+ (NSValueTransformer *)balloonsJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:Balloon.class];
}

+ (NSValueTransformer *)averageColorJSONTransformer
{
    return [MTLValueTransformer valueTransformerForName:ColorTransformerName];
}


#pragma mark - Instance methods

-(NSURLRequest *)buildUrlRequestForDimensions:(CGSize)dimensions
{
    NSURL *url = [NSURL URLWithString:[Helper getImageWithUrl:self.imageUrl size:dimensions]];
    
    NSURLRequestCachePolicy cachePolicy = PanelCachePolicy;
    
    AFNetworkReachabilityStatus networkStatus = [[[APIClient sharedConnection] reachabilityManager] networkReachabilityStatus];
    if ((networkStatus == AFNetworkReachabilityStatusUnknown)
        || (networkStatus == AFNetworkReachabilityStatusNotReachable)) {
        
        cachePolicy = NSURLRequestReturnCacheDataDontLoad;
    }
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:cachePolicy
                                            timeoutInterval:TimeoutInterval];
    
    return urlRequest;
}

- (UIImage *)thumbSizeImage
{
    NSURLRequest *urlRequest = [self buildUrlRequestForDimensions:self.thumbSize];
    UIImage *image = [[UIImageView sharedImageCache] cachedImageForRequest:urlRequest];
    
    return image;
}

- (UIImage *)fullSizeImage
{
    NSURLRequest *urlRequest = [self buildUrlRequestForDimensions:self.dimensions];
    UIImage *image = [[UIImageView sharedImageCache] cachedImageForRequest:urlRequest];
    
    return image;
}


#pragma mark - Getters/setters

- (BOOL)hasThumbSizeImage
{
    NSURLRequest *urlRequest = [self buildUrlRequestForDimensions:self.thumbSize];
    UIImage *image = [[UIImageView sharedImageCache] cachedImageForRequest:urlRequest];
 
    return (image != nil);
}

- (BOOL)hasFullSizeImage
{
    NSURLRequest *urlRequest = [self buildUrlRequestForDimensions:self.dimensions];
    UIImage *image = [[UIImageView sharedImageCache] cachedImageForRequest:urlRequest];
    
    return (image != nil);
}

- (BOOL)isFailed
{
    return _failed;
}

@end
