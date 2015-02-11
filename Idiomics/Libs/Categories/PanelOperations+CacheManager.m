//
//  PanelOperations+CacheManager.m
//  Idiomics
//
//  Created by Joe Mocquant on 2/9/15.
//  Copyright (c) 2015 Idiomics. All rights reserved.
//

#import "PanelOperations+CacheManager.h"
#import "Helper.h"
#import "Panel.h"
#import <RXCollection.h>

@implementation PanelOperations (CacheManager)


- (CGFloat)getTresholdedResForOriginArea:(CGFloat)originArea
                             desiredArea:(CGFloat)desiredArea
{
    if (desiredArea > (ThresholdResolution * originArea)) {
        return originArea;
    }
    
    return desiredArea;
}

- (NSArray *)getTresholdedResolutionsForPanel:(Panel *)panel
{
    CGFloat width;
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    
    if ([Helper isIPhoneDevice]) {
        width = screen.size.width / kColumnsiPhonePortrait;
    } else {
        width = MIN(screen.size.height / kColumnsiPadPortrait,
                    screen.size.width / kColumnsiPadPortrait);
    }
    
    NSMutableArray *resolutions = [NSMutableArray arrayWithArray:@[[NSValue valueWithCGSize:CGSizeMake(width, width * (1 + RelativeHeightRandomModifier))],
                                                                   [NSValue valueWithCGSize:CGSizeMake(2 * width, 2 * width * (1 + RelativeHeightRandomModifier))],
                                                                   [NSValue valueWithCGSize:CGSizeMake(panel.dimensions.width, panel.dimensions.height)]]];
    
    CGFloat originArea = panel.dimensions.width * panel.dimensions.height;
    
    resolutions = [resolutions rx_mapWithBlock:^id(NSValue *resolution) {
        
        CGSize res = [resolution CGSizeValue];
        CGFloat area = res.width * res.height;
        
        if ([self getTresholdedResForOriginArea:originArea desiredArea:area] == originArea) {
            return [NSValue valueWithCGSize:CGSizeMake(panel.dimensions.width, panel.dimensions.height)];
        }
        return resolution;
        
    }];
    
    return [NSArray arrayWithArray:[[[NSOrderedSet alloc] initWithArray:[NSArray arrayWithArray:resolutions]] array]];
}

- (NSCachedURLResponse *)getCachedURLResponseForPanel:(Panel *)panel
                                       withDesiredRes:(CGSize)desiredRes
{
    NSArray *resolutions = [self getTresholdedResolutionsForPanel:panel];
    
    CGFloat originArea = panel.dimensions.width * panel.dimensions.height;
    CGFloat desiredArea = desiredRes.width * desiredRes.height;
    
    if ([self getTresholdedResForOriginArea:originArea desiredArea:desiredArea] == originArea) {
        desiredRes = CGSizeMake(panel.dimensions.width, panel.dimensions.height);
        desiredArea = originArea;
    }
    
    __block NSCachedURLResponse *cachedURLResponse = nil;
    
    [resolutions enumerateObjectsUsingBlock:^(NSValue *resolution, NSUInteger idx, BOOL *stop) {
        
        CGSize res = [resolution CGSizeValue];
        CGFloat area = res.width * res.height;
        
        if (desiredArea == area) {
            
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(idx, resolutions.count - idx)];
            [resolutions enumerateObjectsAtIndexes:indexes options:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                NSURLRequest *request = [self buildUrlRequestForPanel:panel dimensions:res];
                cachedURLResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
                
                if (cachedURLResponse) {
                    *stop = YES;
                }
            }];
            
            *stop = YES;
        }
    }];
    
    return cachedURLResponse;
}

@end