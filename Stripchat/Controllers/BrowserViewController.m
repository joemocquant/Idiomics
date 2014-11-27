//
//  BrowserViewController.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
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
#import "ResizedPanelDownloader.h"
#import "FullSizePanelDownloader.h"
#import "TransitionAnimator.h"
#import <ReactiveCocoa.h>
#import <Mantle.h>
#import <UIView+AutoLayout.h>

@implementation BrowserViewController


#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _pendingOperations = [PendingOperations new];
    mosaicDatas = [NSMutableArray new];
    
    [self loadAllPannels];

    cv = [[UICollectionView alloc] initWithFrame:CGRectZero
                            collectionViewLayout:[MosaicLayout new]];
    
    [(MosaicLayout *)cv.collectionViewLayout setDelegate:self];
    [cv setDelegate:self];
    [cv setDataSource:self];
    [cv registerClass:[MosaicCell class] forCellWithReuseIdentifier:@"cell"];
    
    [self.view addSubview:cv];
    
    [cv setTranslatesAutoresizingMaskIntoConstraints:NO];
    [cv pinEdges:JRTViewPinAllEdges toSameEdgesOfView:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Rotation

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                               duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    MosaicLayout *layout = (MosaicLayout *)cv.collectionViewLayout;
    [layout invalidateLayout];
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
                [Helper showErrorWithMsg:NSLocalizedStringFromTable(@"STRIPCHAT_ERROR", @"Stripchat" , nil)
                                delegate:nil];
                break;
                
            default:
                [Helper showErrorWithMsg:NSLocalizedStringFromTable(@"STRIPCHAT_ERROR", @"Stripchat" , nil)
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
    NSUInteger retVal = 0;
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
    static NSString *cellIdentifier = @"cell";
    MosaicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                 forIndexPath:indexPath];

    Panel *panel = [[[PanelStore sharedStore] allPanels] objectAtIndex:indexPath.item];
    
    cell.backgroundColor = panel.averageColor;
    
    if ([panel hasThumbImage]) {
        cell.mosaicData = [mosaicDatas objectAtIndex:indexPath.item];
        
    } else if ([panel isFailed]) {

        //better to remove the panel than putting a placeholder
        //add to implement a remove method on PanelStore and call it here
        
    } else {
        if (!collectionView.dragging) {
            [self startOperationsForPanel:panel atIndexPath:indexPath];
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
    Panel *panel = [[[PanelStore sharedStore] allPanels] objectAtIndex:indexPath.item];
    
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
    
    if (timeDiff > 0.1) {
        CGFloat distance = currentOffset.y - lastOffset.y;

        CGFloat scrollSpeed = fabsf(distance * 10 / 1000); //per millisecond
        
        if (scrollSpeed > 1.0) {
            isScrollingFast = YES;
        } else {
            isScrollingFast = NO;
            [self loadPanelsForOnScreenItems];
            [self resumeAllOperations];
        }
        
        lastOffset = currentOffset;
        lastOffsetTime = currentTime;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadPanelsForOnScreenItems];
    [self resumeAllOperations];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self suspendAllOperations];
}


#pragma mark - Operations

- (void)startOperationsForPanel:(Panel *)panel atIndexPath:(NSIndexPath *)indexPath
{
    if (!panel.hasThumbImage) {
        [self startResizeOperationForPanel:panel atIndexPath:indexPath];
    }
    
    if (!panel.hasFullSizeImage) {
        [self startFullSizeOperationsForPanel:panel atIndexPath:indexPath];
    }
}

- (void)startResizeOperationForPanel:(Panel *)panel atIndexPath:(NSIndexPath *)indexPath
{
    if (![self.pendingOperations.resizedPanelDownloadsInProgress.allKeys containsObject:indexPath]) {
            
        ResizedPanelDownloader *rpd = [[ResizedPanelDownloader alloc] initWithPanel:panel
                                                                        atIndexPath:indexPath
                                                                           delegate:self];
            
        [self.pendingOperations.resizedPanelDownloadsInProgress setObject:rpd forKey:indexPath];
        [self.pendingOperations.resizedPanelDownloadsQueue addOperation:rpd];
    }
}

- (void)startFullSizeOperationsForPanel:(Panel *)panel atIndexPath:(NSIndexPath *)indexPath
{
    if (![self.pendingOperations.fullSizePanelDownloadsInProgress.allKeys containsObject:indexPath]) {
            
        FullSizePanelDownloader *fspd = [[FullSizePanelDownloader alloc] initWithPanel:panel
                                                                           atIndexPath:indexPath
                                                                              delegate:self];
        
        
        ResizedPanelDownloader *rpd = [self.pendingOperations.resizedPanelDownloadsInProgress objectForKey:indexPath];
        if (rpd) {
            [fspd addDependency:rpd];
        }
        
        [self.pendingOperations.fullSizePanelDownloadsInProgress setObject:fspd forKey:indexPath];
        [self.pendingOperations.fullSizePanelDownloadsQueue addOperation:fspd];
    }
}

- (void)suspendAllOperations
{
    [self.pendingOperations.resizedPanelDownloadsQueue setSuspended:YES];
}


- (void)resumeAllOperations
{
    [self.pendingOperations.resizedPanelDownloadsQueue setSuspended:NO];
}


- (void)cancelAllOperations
{
    [self.pendingOperations.resizedPanelDownloadsQueue cancelAllOperations];
}

- (void)loadPanelsForOnScreenItems
{
    NSSet *visibleItems = [NSSet setWithArray:[cv indexPathsForVisibleItems]];
    
    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[self.pendingOperations.resizedPanelDownloadsInProgress allKeys]];
    [pendingOperations addObjectsFromArray:[self.pendingOperations.fullSizePanelDownloadsInProgress allKeys]];
    
    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
    NSMutableSet *toBeStarted = [visibleItems mutableCopy];
    
    [toBeStarted minusSet:pendingOperations];
    [toBeCancelled minusSet:visibleItems];
    
    for (NSIndexPath *indexPath in toBeCancelled) {
        
        //Should include a check to cancel only those below 60%
        
        ResizedPanelDownloader *pendingResizingDownload = [self.pendingOperations.resizedPanelDownloadsInProgress objectForKey:indexPath];
        [pendingResizingDownload cancel];
        [self.pendingOperations.resizedPanelDownloadsInProgress removeObjectForKey:indexPath];
        
        FullSizePanelDownloader *pendingFullSizeDownload = [self.pendingOperations.fullSizePanelDownloadsInProgress objectForKey:indexPath];
        [pendingFullSizeDownload cancel];
        [self.pendingOperations.fullSizePanelDownloadsInProgress removeObjectForKey:indexPath];
        
#ifdef __DEBUG__
        NSLog(@"Canceled task %ld", (long)indexPath.item);
#endif
        
    }
    
    for (NSIndexPath *indexPath in toBeStarted) {

        Panel *panel = [[[PanelStore sharedStore] allPanels] objectAtIndex:indexPath.item];
        [self startOperationsForPanel:panel atIndexPath:indexPath];
    }
}


#pragma mark - ResizedPanelDownloaderDelegate

- (void)resizedPanelDownloaderDidFinish:(ResizedPanelDownloader *)downloader
{
    [cv reloadItemsAtIndexPaths:[NSArray arrayWithObject:downloader.indexPath]];
    //[self.pendingOperations.resizedPanelDownloadsInProgress removeObjectForKey:downloader.indexPath];
    
#ifdef __DEBUG__
    NSLog(@"Finished resizing task %ld", (long)downloader.indexPath.item);
#endif
}


#pragma mark - FullSizePanelDownloaderDelegate

- (void)fullSizePanelDownloaderDidFinish:(FullSizePanelDownloader *)downloader
{
    //[self.pendingOperations.fullSizePanelDownloadsInProgress removeObjectForKey:downloader.indexPath];
    
#ifdef __DEBUG__
    NSLog(@"Finished fullSize task %ld", (long)downloader.indexPath.item);
#endif
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
