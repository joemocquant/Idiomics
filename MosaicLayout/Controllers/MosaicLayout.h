//
//  MosaicLayout.h
//  MosaicCollectionView
//
//  Created by Ezequiel A Becerra on 2/16/13.
//  Modified by Joe Mocquant on 11/23/14.
//  Copyright (c) 2013 Betzerra. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MosaicLayoutDelegate <NSObject>

/*  Returns the relative height of a particular cell at an index path.
 *
 *  Relative height means how tall the cell will be in comparisson with its width.
 *  i.e. if the relative height is 1, the cell is square.
 *  If the relative height is 2, the cell has twice the height than its width. */
- (float)collectionView:(UICollectionView *)collectionView relativeHeightForItemAtIndexPath:(NSIndexPath *)indexPath;

/*  Returns if the cell at a particular index path can be shown as "double column"
 *
 *  That doesn't mean it WILL be displayed as "double column" because it needs 2 consecutive
 *  columns with the same size */
- (BOOL)collectionView:(UICollectionView *)collectionView isDoubleColumnAtIndexPath:(NSIndexPath *)indexPath;

//  Returns the amount of columns that have to display at that moment
- (NSUInteger)numberOfColumnsInCollectionView:(UICollectionView *)collectionView;

@end


@interface MosaicLayout : UICollectionViewLayout
{
    NSMutableArray *columnHeights;
    NSMutableArray *itemsAttributes;
}

@property (nonatomic, weak) id<MosaicLayoutDelegate> delegate;

@end
