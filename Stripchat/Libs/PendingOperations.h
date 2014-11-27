//
//  PendingOperations.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/24/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PendingOperations : NSObject

@property (nonatomic, strong) NSMutableDictionary *resizedPanelDownloadsInProgress;
@property (nonatomic, strong) NSOperationQueue *resizedPanelDownloadsQueue;

@property (nonatomic, strong) NSMutableDictionary *fullSizePanelDownloadsInProgress;
@property (nonatomic, strong) NSOperationQueue *fullSizePanelDownloadsQueue;

@end
