//
//  BrowserViewController.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PanelImageStore.h"
#import "MosaicCell.h"
#import "MosaicLayout.h"

@interface BrowserViewController : UIViewController <PanelImageStoreDelegate,
                                                     MosaicLayoutDelegate,
                                                     UICollectionViewDelegate,
                                                     UICollectionViewDataSource,
                                                     UIViewControllerTransitioningDelegate>
{
    UICollectionView *cv;
    MosaicCell *selectedCell;
}

@end
