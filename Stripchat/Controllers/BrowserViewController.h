//
//  BrowserViewController.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MosaicCell.h"
#import "MosaicLayout.h"
#import "PendingOperations.h"
#import "ResizedPanelDownloader.h"

@interface BrowserViewController : UIViewController <MosaicLayoutDelegate,
                                                     UICollectionViewDelegate,
                                                     UICollectionViewDataSource,
                                                     UIViewControllerTransitioningDelegate,
                                                     ResizedPanelDownloaderDelegate>
{
    UICollectionView *cv;
    MosaicCell *selectedCell;
    NSMutableArray *mosaicDatas;
}

@property (nonatomic, strong) PendingOperations *pendingOperations;

@end
