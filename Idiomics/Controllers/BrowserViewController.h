//
//  BrowserViewController.h
//  Idiomics
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackingViewController.h"
#import "MosaicLayout.h"
#import "PendingOperations.h"

@class MosaicCell;

@interface BrowserViewController : TrackingViewController <MosaicLayoutDelegate,
                                                           UICollectionViewDelegate,
                                                           UICollectionViewDataSource,
                                                           PendingOperationsDelegate,
                                                           UIViewControllerTransitioningDelegate>
{
    PendingOperations *pendingOperations;
    
    UICollectionView *cv;
    MosaicCell *selectedCell;
    NSMutableArray *mosaicDatas;
    
    CGPoint lastOffset;
    NSTimeInterval lastOffsetTime;
    BOOL isScrollingFast;
}

@end
