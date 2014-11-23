//
//  MosaicDataView.h
//  MosaicCollectionView
//
//  Created by Ezequiel A Becerra on 2/16/13.
//  Modified by Joe Mocquant on 11/23/14.
//  Copyright (c) 2013 Betzerra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MosaicData.h"

@interface MosaicCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong) MosaicData *mosaicData;

@end
