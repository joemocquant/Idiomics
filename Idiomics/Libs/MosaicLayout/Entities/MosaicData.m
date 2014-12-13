//
//  MosaicData.m
//  MosaicCollectionView
//
//  Created by Ezequiel A Becerra on 2/17/13.
//  Modified by Joe Mocquant on 11/23/14.
//  Copyright (c) 2013 Betzerra. All rights reserved.
//

#import "MosaicData.h"

@implementation MosaicData

- (instancetype)initWithImageId:(NSString *)imageId
{
    self = [self init];
    if (self) {
        _imageId = imageId;
        _firstTimeShown = YES;
    }
    return self;
}

@end
