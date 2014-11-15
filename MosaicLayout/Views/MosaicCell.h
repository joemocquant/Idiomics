//
//  MosaicDataView.h
//  MosaicCollectionView
//
//  Created by Ezequiel A Becerra on 2/16/13.
//  Copyright (c) 2013 Betzerra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MosaicData.h"

@interface MosaicCell : UICollectionViewCell
{
    UIView *_borderView;
    UIImageView *_imageView;
    MosaicData *_mosaicData;
}

@property (strong) UIImage *image;
@property (strong) MosaicData *mosaicData;

- (UIImageView *)imageView;

@end
