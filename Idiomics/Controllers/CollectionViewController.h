//
//  CollectionViewController.h
//  Idiomics
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackingViewController.h"
#import "MosaicLayout.h"
#import "PanelOperations.h"

@class MosaicCell;

@interface CollectionViewController : TrackingViewController <MosaicLayoutDelegate,
                                                              UICollectionViewDelegate,
                                                              UICollectionViewDataSource,
                                                              PanelOperationsDelegate,
                                                              UIViewControllerTransitioningDelegate>
{
    PanelOperations *panelOperations;
    
    UICollectionView *cv;
    UIButton *back;
    MosaicCell *selectedCell;
    NSMutableArray *mosaicDatas;
    
    CGPoint lastOffset;
    NSTimeInterval lastOffsetTime;
    BOOL isScrollingFast;
}

@end
