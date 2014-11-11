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
#import "PanelView.h"
#import <ReactiveCocoa.h>
#import <Mantle.h>
#import <UIView+AutoLayout.h>

#define kColumnsiPadLandscape 5
#define kColumnsiPadPortrait 4
#define kColumnsiPhoneLandscape 3
#define kColumnsiPhonePortrait 2
#define kDoubleColumnProbability 40

@implementation BrowserViewController


#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[PanelImageStore sharedStore] setDelegate:self];
    [self loadAllPannels];

    cv = [[UICollectionView alloc] initWithFrame:CGRectZero
                            collectionViewLayout:[[MosaicLayout alloc] init]];
    
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
                    [[PanelStore sharedStore] addPanel:p];
                };
                
                [[PanelImageStore sharedStore] setAllPanelImages];
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
    
    [[APIClient sharedConnection] getAllPanelsWithSuccessHandler:successHandler
                                                    errorHandler:errorHandler];
}


#pragma mark - PanelImageStoreDelegate

- (void)didLoadPanelWithPanelKey:(NSString *)key
{
    NSLog(@"Panel id:%@ loaded", key);
}

- (void)didLoadAllPanels
{
    NSLog(@"did load all panels!");
}


#pragma mark - MosaicLayoutDelegate

- (float)collectionView:(UICollectionView *)collectionView relativeHeightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //Base relative height for simple layout type. This is 1.0 (height equals to width)
    float retVal = 1.0;
    
    Panel *panel = [[[PanelStore sharedStore] allPanels] objectAtIndex:indexPath.row];
    NSDictionary *dictionary = @{@"imageFilename": panel.imageUrl,
                                 @"title": @""};
    
    MosaicData *aMosaicModule = [[MosaicData alloc] initWithDictionary:dictionary];
    
    if (aMosaicModule.relativeHeight != 0){
        
        //If the relative height was set before, return it
        retVal = aMosaicModule.relativeHeight;
        
    } else {
        
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
    }
    
    return retVal;
}

- (BOOL)collectionView:(UICollectionView *)collectionView isDoubleColumnAtIndexPath:(NSIndexPath *)indexPath
{
    Panel *panel = [[[PanelStore sharedStore] allPanels] objectAtIndex:indexPath.row];
    NSDictionary *dictionary = @{@"imageFilename": panel.imageUrl,
                                 @"title": @""};
    
    MosaicData *aMosaicModule = [[MosaicData alloc] initWithDictionary:dictionary];
    
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

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [[[PanelStore sharedStore] allPanels] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    MosaicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                 forIndexPath:indexPath];
    
    Panel *panel = [[[PanelStore sharedStore] allPanels] objectAtIndex:indexPath.row];
    NSDictionary *dictionary = @{@"imageFilename": panel.imageUrl,
                                 @"title": @""};
    
    MosaicData *data = [[MosaicData alloc] initWithDictionary:dictionary];
    cell.mosaicData = data;
    
    float randomWhite = (arc4random() % 40 + 10) / 255.0;
    cell.backgroundColor = [UIColor colorWithWhite:randomWhite alpha:1];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.view subviews].count == 2) {
        return;
    }
    
    MosaicCell *selectedCell = (MosaicCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *cellImageView = selectedCell.imageView;
    
    PanelView *panelView = [[PanelView alloc] initWithCell:cellImageView];
    [self.view addSubview:panelView];
    [panelView becomeFirstResponder];
    
    [panelView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [panelView pinEdges:JRTViewPinAllEdges toSameEdgesOfView:self.view];
    
    //should be calculated instead of setting 10.0
    [panelView.panelScrollView setMaximumZoomScale:10.0];
    
    CGRect tempPoint = CGRectMake(cellImageView.center.x, cellImageView.center.y, 0, 0);
    CGRect startingPoint = [self.view convertRect:tempPoint fromView:selectedCell];
    
    [panelView setFrame:startingPoint];

    [UIView animateWithDuration:0.2
                     animations:^{
                         [panelView setFrame:CGRectMake(0,
                                                        0,
                                                        self.view.bounds.size.width,
                                                        self.view.bounds.size.height)];
                         
                         [panelView.panelScrollView setFrame:CGRectMake(0,
                                                        0,
                                                        self.view.bounds.size.width,
                                                        self.view.bounds.size.height)];
                        }];
}

@end