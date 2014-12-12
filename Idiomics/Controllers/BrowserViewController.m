//
//  BrowserViewController.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "BrowserViewController.h"
#import "APIClient.h"
#import "Helper.h"
#import "Panel.h"
#import "PanelStore.h"
#import "MosaicLayout.h"
#import "MosaicCell.h"
#import "MosaicData.h"
#import "PanelViewController.h"
#import "TransitionAnimator.h"
#import <Mantle.h>
#import <UIView+AutoLayout.h>
#import <GAI.h>
#import <GAIDictionaryBuilder.h>

@implementation BrowserViewController


#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    pendingOperations = [PendingOperations new];
    [pendingOperations setDelegate:self];
    
    mosaicDatas = [NSMutableArray new];
    
    [self loadAllPannels];

    cv = [[UICollectionView alloc] initWithFrame:CGRectZero
                            collectionViewLayout:[MosaicLayout new]];
    
    [(MosaicLayout *)cv.collectionViewLayout setDelegate:self];
    [cv setDelegate:self];
    [cv setDataSource:self];
    [cv registerClass:[MosaicCell class] forCellWithReuseIdentifier:CellIdentifier];
    
    [self.view addSubview:cv];
    
    [cv setTranslatesAutoresizingMaskIntoConstraints:NO];
    [cv pinEdges:JRTViewPinAllEdges toSameEdgesOfView:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Rotation iPad

//iOS 7.x
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                               duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    MosaicLayout *layout = (MosaicLayout *)cv.collectionViewLayout;
    [layout invalidateLayout];
}

//iOS 8.x
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
  
        MosaicLayout *layout = (MosaicLayout *)cv.collectionViewLayout;
        [layout invalidateLayout];
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
    }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


#pragma mark - Private methods

- (void)loadAllPannels
{
    SuccessHandler successHandler = ^(NSURLSessionDataTask *operation, id responseObject) {
        switch (((NSHTTPURLResponse *)[operation response]).statusCode) {
                
            case 200:
                //OK
            {
                NSDictionary *panels = [[responseObject objectForKey:@"rows"] valueForKey:@"value"];
                
                for (NSDictionary *panel in panels) {
                    
                    Panel *p = [MTLJSONAdapter modelOfClass:Panel.class fromJSONDictionary:panel error:nil];
                    [mosaicDatas addObject:[[MosaicData alloc] initWithImageId:p.imageUrl]];
                    [[PanelStore sharedStore] addPanel:p];
                };
                [cv reloadData];
                break;
            }
                
            default:
                break;
        }
    };
    
    ErrorHandler errorHandler = ^(NSURLSessionDataTask *operation, id responseObject) {
        switch (((NSHTTPURLResponse *)[operation response]).statusCode) {
                
            case 404:
                [Helper showErrorWithMsg:NSLocalizedStringFromTable(@"IDIOMICS_ERROR", @"Idiomics" , nil)
                                delegate:nil];
                break;
                
            default:
                [Helper showErrorWithMsg:NSLocalizedStringFromTable(@"IDIOMICS_ERROR", @"Idiomics" , nil)
                                delegate:nil];
                break;
        }
    };
    
    [[APIClient sharedConnection] getSingleBalloonPanelsWithSuccessHandler:successHandler
                                                              errorHandler:errorHandler];
}


#pragma mark - MosaicLayoutDelegate

- (float)collectionView:(UICollectionView *)collectionView relativeHeightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Base relative height for simple layout type. This is 1.0 (height equals to width)
    float retVal = 1.0;
    
    MosaicData *aMosaicModule = [mosaicDatas objectAtIndex:indexPath.item];
    
    if (aMosaicModule.relativeHeight != 0) {
        return aMosaicModule.relativeHeight;
    }
    
    BOOL isDoubleColumn = [self collectionView:collectionView isDoubleColumnAtIndexPath:indexPath];
    if (isDoubleColumn) {
        //Base relative height for double layout type. This is 0.75 (height equals to 75% width)
        retVal = 0.75;
    }
        
    /*  Relative height random modifier. The max height of relative height is 25% more than
     *  the base relative height */
        
    float extraRandomHeight = arc4random() % 25;
    retVal = retVal + (extraRandomHeight / 100);
    
    /*  Persist the relative height on MosaicData so the value will be the same every time
     *  the mosaic layout invalidates */
        
    aMosaicModule.relativeHeight = retVal;

    return retVal;
}

- (BOOL)collectionView:(UICollectionView *)collectionView isDoubleColumnAtIndexPath:(NSIndexPath *)indexPath
{
    MosaicData *aMosaicModule = [mosaicDatas objectAtIndex:indexPath.item];
    
    if (aMosaicModule.layoutType == kMosaicLayoutTypeUndefined) {
        
        /*  First layout. We have to decide if the MosaicData should be
         *  double column (if possible) or not. */
        
        NSUInteger random = arc4random() % 100;
        if (random < kDoubleColumnProbability) {
            aMosaicModule.layoutType = kMosaicLayoutTypeDouble;
        } else {
            aMosaicModule.layoutType = kMosaicLayoutTypeSingle;
        }
    }
    
    BOOL retVal = aMosaicModule.layoutType == kMosaicLayoutTypeDouble;
    
    return retVal;
}

- (NSUInteger)numberOfColumnsInCollectionView:(UICollectionView *)collectionView
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    //  Set the quantity of columns according of the device and interface orientation
    NSUInteger retVal;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            retVal = kColumnsiPadLandscape;
        } else {
            retVal = kColumnsiPhoneLandscape;
        }
        
    } else {
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            retVal = kColumnsiPadPortrait;
        } else {
            retVal = kColumnsiPhonePortrait;
        }
    }
    
    return retVal;
}


#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MosaicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier
                                                                 forIndexPath:indexPath];

    Panel *panel = [[PanelStore sharedStore] panelAtIndex:indexPath.item];
    
    cell.backgroundColor = panel.averageColor;
    
    if ([panel hasThumbImage]) {
        cell.mosaicData = [mosaicDatas objectAtIndex:indexPath.item];
        
    } else if ([panel isFailed]) {

        //better to remove the panel than putting a placeholder
        //add to implement a remove method on PanelStore and call it here
        
    } else {
        if (!collectionView.dragging) {
            [pendingOperations startOperationsForPanel:panel atIndexPath:indexPath];
        }
    }

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [[[PanelStore sharedStore] allPanels] count];
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"button_press"
                                                           label:@"panel_selection"
                                                           value:nil] build]];
    
    Panel *panel = [[PanelStore sharedStore] panelAtIndex:indexPath.item];
    
    if (!panel.hasFullSizeImage) {
        return;
    }
    
    selectedCell = (MosaicCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    PanelViewController *pvc = [[PanelViewController alloc] initWithPanel:panel];

    [pvc setTransitioningDelegate:self];
    [pvc setModalPresentationStyle:UIModalPresentationCustom];
    
    [self presentViewController:pvc animated:YES completion:nil];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint currentOffset = scrollView.contentOffset;
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    NSTimeInterval timeDiff = currentTime - lastOffsetTime;
    
    if (timeDiff > TimeDiff) {
        CGFloat distance = currentOffset.y - lastOffset.y;

        CGFloat scrollSpeed = fabsf(distance * 10 / 1000); //per millisecond
        
        if (scrollSpeed > ScrollSpeedThreshold) {
            isScrollingFast = YES;
        } else {
            isScrollingFast = NO;
            [pendingOperations loadPanelsForIndexPaths:[cv indexPathsForVisibleItems]];
            [pendingOperations resumeAllOperations];
        }
        
        lastOffset = currentOffset;
        lastOffsetTime = currentTime;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [pendingOperations loadPanelsForIndexPaths:[cv indexPathsForVisibleItems]];
    [pendingOperations resumeAllOperations];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.x >= VelocityThreshold) {
        [pendingOperations suspendAllOperations];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pendingOperations loadPanelsForIndexPaths:[cv indexPathsForVisibleItems]];
    [pendingOperations resumeAllOperations];
}


#pragma mark - PendingOperationsDelegate

- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths
{
    [cv reloadItemsAtIndexPaths:indexPaths];
}


#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    TransitionAnimator *animator = [TransitionAnimator new];
    
    animator.presenting = YES;
    animator.selectedCell = selectedCell;
    
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    TransitionAnimator *animator = [TransitionAnimator new];
    animator.presenting = NO;
    animator.selectedCell = selectedCell;
    
    return animator;
}

@end
