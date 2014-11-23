//
//  MosaicData.h
//  MosaicCollectionView
//
//  Created by Ezequiel A Becerra on 2/17/13.
//  Modified by Joe Mocquant on 11/23/14.
//  Copyright (c) 2013 Betzerra. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kMosaicLayoutTypeUndefined,
    kMosaicLayoutTypeSingle,
    kMosaicLayoutTypeDouble
} MosaicLayoutType;

@interface MosaicData : NSObject

@property (nonatomic, copy, readonly) NSString *imageId;
@property (nonatomic, assign) BOOL firstTimeShown;
@property (nonatomic, assign) MosaicLayoutType layoutType;
@property (nonatomic, assign) float relativeHeight;

- (instancetype)initWithImageId:(NSString *)imageId;

@end
