//
//  UniverseViewController.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "UniverseViewController.h"
#import "APIClient.h"
#import "Helper.h"
#import "MosaicLayout.h"
#import "MosaicCell.h"
#import "MosaicData.h"
#import "Panel.h"
#import "Universe.h"
#import "UniverseStore.h"
#import "NSMutableArray+Shuffling.h"
#import "PanelViewController.h"
#import "TransitionAnimator.h"
#import <Mantle.h>
#import <UIView+AutoLayout.h>
#import <GAI.h>
#import <GAIDictionaryBuilder.h>

@implementation UniverseViewController


#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        itemId = [UniverseStore sharedStore].currentUniverse.universeId;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationController.navigationBarHidden = YES;
    
    panelOperations = [PanelOperations new];
    panelOperations.delegate = self;
    
    mosaicDatas = [NSMutableArray new];

    cv = [[UICollectionView alloc] initWithFrame:CGRectZero
                            collectionViewLayout:[MosaicLayout new]];
    
    ((MosaicLayout *)cv.collectionViewLayout).delegate = self;
    cv.showsVerticalScrollIndicator = NO;
    cv.delegate = self;
    cv.dataSource = self;
    [cv registerClass:[MosaicCell class] forCellWithReuseIdentifier:CellIdentifier];
    [self.view addSubview:cv];
    
    cv.translatesAutoresizingMaskIntoConstraints = NO;
    [cv pinEdges:JRTViewPinAllEdges toSameEdgesOfView:self.view];
    
    back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setImage:[UIImage imageNamed:@"collections.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backToLibrary) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
    
    back.translatesAutoresizingMaskIntoConstraints = NO;
    [back constrainToSize:CGSizeMake(NavigationControlHeight, NavigationControlHeight)];
    [back pinEdges:JRTViewPinLeftEdge | JRTViewPinTopEdge toSameEdgesOfView:self.view];
    
    [self loadAllPannels];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[[UniverseStore sharedStore] currentUniverse] deleteAllPanels];
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

- (void)backToLibrary
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadAllPannels
{
    SuccessHandler successHandler = ^(NSURLSessionDataTask *operation, id responseObject) {
        switch (((NSHTTPURLResponse *)operation.response).statusCode) {
                
            case 200:
                //OK
            {
                NSMutableArray *panels =  [NSMutableArray arrayWithArray:[[responseObject objectForKey:@"rows"] valueForKey:@"value"]];
                [panels shuffle];
                
                for (NSDictionary *panel in panels) {
                    
                    Panel *p = [MTLJSONAdapter modelOfClass:Panel.class fromJSONDictionary:panel error:nil];
                    [mosaicDatas addObject:[[MosaicData alloc] initWithPanel:p]];
                    [[UniverseStore sharedStore].currentUniverse addPanel:p];
                };
                
                [cv reloadData];
                break;
            }
                
            default:
                break;
        }
    };
    
    ErrorHandler errorHandler = ^(NSURLSessionDataTask *operation, id responseObject) {
        switch (((NSHTTPURLResponse *)operation.response).statusCode) {
                
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
    
    [[APIClient sharedConnection] getAllPanelForUniverse:[UniverseStore sharedStore].currentUniverse.universeId
                                          successHandler:successHandler
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
        retVal = 1 - RelativeHeightRandomModifier;
    }
        
    /*  Relative height random modifier. The max height of relative height is 25% more than
     *  the base relative height */
        
    float extraRandomHeight = arc4random() % ((int) (RelativeHeightRandomModifier * 100));
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
    
    return aMosaicModule.layoutType == kMosaicLayoutTypeDouble;
}

- (NSUInteger)numberOfColumnsInCollectionView:(UICollectionView *)collectionView
{
     NSUInteger retVal;
    
    if ([Helper isIPhoneDevice]) {
        retVal = kColumnsiPhonePortrait;
    } else {
        
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            retVal = kColumnsiPadLandscape;
        } else {
            retVal = kColumnsiPadPortrait;
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

    Panel *panel = [[UniverseStore sharedStore].currentUniverse panelAtIndex:indexPath.item];
    
    cell.backgroundColor = panel.averageColor;
    
    if (panel.hasThumbSizeImage) {

#ifdef __DEBUG__
        NSLog(@"Accessing in memorry resource (resized task %ld)", (long)indexPath.item);
#endif
        
        cell.mosaicData = [mosaicDatas objectAtIndex:indexPath.item];

    } else if (panel.isFailed) {

        //better to remove the panel than putting a placeholder
        //add to implement a remove method on PanelStore and call it here
        
    } else {
        if (!collectionView.dragging) {
            [panelOperations startOperationsForPanel:panel atIndexPath:indexPath];
        }
    }

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [[UniverseStore sharedStore].currentUniverse allPanels].count;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Panel *panel = [[UniverseStore sharedStore].currentUniverse panelAtIndex:indexPath.item];
    
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"panel_selection"
                                                           label:panel.panelId
                                                           value:nil] build]];
    
    if (!panel.hasFullSizeImage) {
        return;
    }
    
    selectedCell = (MosaicCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    PanelViewController *pvc = [[PanelViewController alloc] initWithPanel:panel];

    pvc.transitioningDelegate = self;
    pvc.modalPresentationStyle = UIModalPresentationCustom;
    
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

        if (currentOffset.y > 0 && ABS(distance) > DistanceMin) {
            [UIView animateWithDuration:MenuMoveDuration animations:^{
                
                CGPoint center = back.center;
                if (distance < 0) { // scrolling up
                    
                    if (center.y < 0) {
                        back.alpha = 1.0;
                        back.center = CGPointMake(center.x, center.y + NavigationControlHeight);
                    }
                } else { // scrolling down
                    
                    if (center.y > 0) {
                        back.alpha = 0;
                        back.center = CGPointMake(center.x, center.y - NavigationControlHeight);
                    }
                }
            }];
        }

        CGFloat scrollSpeed = fabsf(distance * 10 / 1000); //per millisecond
        
        if (scrollSpeed > ScrollSpeedThreshold) {
            isScrollingFast = YES;
        } else {
            isScrollingFast = NO;
            [panelOperations loadPanelsForIndexPaths:[cv indexPathsForVisibleItems]];
            [panelOperations resumeAllOperations];
        }
        
        lastOffset = currentOffset;
        lastOffsetTime = currentTime;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [panelOperations loadPanelsForIndexPaths:[cv indexPathsForVisibleItems]];
    [panelOperations resumeAllOperations];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.x >= VelocityThreshold) {
        [panelOperations suspendAllOperations];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [panelOperations loadPanelsForIndexPaths:[cv indexPathsForVisibleItems]];
    [panelOperations resumeAllOperations];
}


#pragma mark - PanelPendingOperationsDelegate

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
