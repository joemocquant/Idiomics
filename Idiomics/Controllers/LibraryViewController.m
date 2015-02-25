//
//  LibraryViewController.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/15/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "LibraryViewController.h"
#import "CollectionViewController.h"
#import "Helper.h"
#import "Colors.h"
#import "Collection.h"
#import "CollectionStore.h"
#import "CollectionViewCell.h"
#import <UIView+AutoLayout.h>
#import <UIImageView+AFNetworking.h>
#import <GAI.h>
#import <GAIDictionaryBuilder.h>
#import <Instabug.h>

@implementation LibraryViewController


#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = YES;
 
    libraryOperations = [LibraryOperations new];
    libraryOperations.delegate = self;
    
    tv = [UITableView new];
    tv.delegate = self;
    tv.dataSource = self;
    tv.showsVerticalScrollIndicator = NO;
    tv.backgroundColor = [Colors black];
    tv.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tv registerClass:CollectionViewCell.class forCellReuseIdentifier:LibraryCellId];
    
    [self.view addSubview:tv];
    tv.translatesAutoresizingMaskIntoConstraints = NO;
    [tv pinEdges:JRTViewPinAllEdges toSameEdgesOfView:self.view];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSIndexPath *selectedIndexPath = [tv indexPathForSelectedRow];
    CollectionViewCell *cell = (CollectionViewCell *)[tv cellForRowAtIndexPath:selectedIndexPath];
    cell.mashupView.alpha = MashupAlpha;
    cell.iconView.alpha = 1.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[CollectionStore sharedStore] allCollections].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LibraryCellId];
    
    if (cell == nil) {
        cell = [[CollectionViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LibraryCellId];
    }
    
    Collection *collection = [[CollectionStore sharedStore] collectionAtIndex:indexPath.row];
    cell.contentView.backgroundColor = collection.averageColor;
    
    [cell.iconView setImageWithURL:[NSURL URLWithString:collection.iconUrl]];
    
    if (collection.hasCoverImage) {
        
        cell.mashupView.image = [collection coverImage];

        [UIView animateWithDuration:AlphaTransitionDuration animations:^{
            cell.mashupView.alpha = MashupAlpha;
        }];

    } else if (collection.isFailed) {
        
        
    } else {
        //if (!tv.dragging) {
            [libraryOperations startOperationsForCollection:collection atIndexPath:indexPath];
        //}
    }
    
    return cell;
}


#pragma mark - UITableViewDelefate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat height;
    
    if ([Helper isIPhoneDevice]) {
        height = CGRectGetHeight(screen) / kRowsiPhonePortrait;
    } else {
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                height = CGRectGetHeight(screen) / kRowsiPadPortrait;
            } else {
                height = CGRectGetWidth(screen) / kRowsiPadLandscape;
            }
        }
        
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            height = CGRectGetHeight(screen) / kRowsiPadPortrait;
        } else {
            height = CGRectGetHeight(screen) / kRowsiPadLandscape;
        }
    }
    
    if (indexPath.row == 0)
        height *= CollectionAllRatio;
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [CollectionStore sharedStore].currentCollection = [[CollectionStore sharedStore] collectionAtIndex:indexPath.row];
    
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"collection_selection"
                                                           label:[CollectionStore sharedStore].currentCollection.collectionId
                                                           value:nil] build]];
    
    CollectionViewController *uvc = [CollectionViewController new];

    [self.navigationController pushViewController:uvc animated:YES];
}


#pragma mark - LibraryOperationsDelegate

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths
{
    [tv reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

@end
