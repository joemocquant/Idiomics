//
//  PendingOperations.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/24/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "PendingOperations.h"

@implementation PendingOperations


#pragma mark - Getters/setters

- (NSMutableDictionary *)resizedPanelDownloadsInProgress
{
    if (!_resizedPanelDownloadsInProgress) {
        _resizedPanelDownloadsInProgress = [NSMutableDictionary dictionary];
    }
    
    return _resizedPanelDownloadsInProgress;
}

- (NSOperationQueue *)resizedPanelDownloadsQueue
{
    if (!_resizedPanelDownloadsQueue) {
        _resizedPanelDownloadsQueue = [NSOperationQueue new];
        _resizedPanelDownloadsQueue.name = @"Resized Panel Downloads Queue";
    }
    
    return _resizedPanelDownloadsQueue;
}

- (NSMutableDictionary *)fullSizePanelDownloadsInProgress
{
    if (!_fullSizePanelDownloadsInProgress) {
        _fullSizePanelDownloadsInProgress = [NSMutableDictionary dictionary];
    }
    
    return _fullSizePanelDownloadsInProgress;
}

- (NSOperationQueue *)fullSizePanelDownloadsQueue
{
    if (!_fullSizePanelDownloadsQueue) {
        _fullSizePanelDownloadsQueue = [NSOperationQueue new];
        _fullSizePanelDownloadsQueue.name = @"Resized Panel Downloads Queue";
    }
    
    return _fullSizePanelDownloadsQueue;
}

@end
