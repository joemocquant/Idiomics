//
//  LibraryViewController.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/15/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "LibraryViewController.h"
#import "CollectionViewController.h"
#import "APIClient.h"
#import "Helper.h"
#import "Colors.h"
#import "Collection.h"
#import "CollectionStore.h"
#import "CollectionViewCell.h"
#import <UIView+AutoLayout.h>
#import <GAI.h>
#import <GAIDictionaryBuilder.h>
#import <Instabug.h>

@interface LibraryViewController ()

@end

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

    [self loadAllCollections];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSIndexPath *selectedIndexPath = [tv indexPathForSelectedRow];
    CollectionViewCell *cell = (CollectionViewCell *)[tv cellForRowAtIndexPath:selectedIndexPath];
    cell.mashupView.alpha = MashupAlpha;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private methods

- (void)loadAllCollections
{
    SuccessHandler successHandler = ^(NSURLSessionDataTask *operation, id responseObject) {
        switch (((NSHTTPURLResponse *)operation.response).statusCode) {
                
            case 200:
                //OK
            {
                for (NSDictionary *collection in responseObject) {
                    
                    Collection *u = [MTLJSONAdapter modelOfClass:Collection.class fromJSONDictionary:collection error:nil];
                    [[CollectionStore sharedStore] addCollection:u];
                };

                [tv reloadData];
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
    
    [[APIClient sharedConnection] getAllCollectionWithSuccessHandler:successHandler
                                                        errorHandler:errorHandler];
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
        cell = [[CollectionViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:LibraryCellId];
    }
    
    Collection *collection = [[CollectionStore sharedStore] collectionAtIndex:indexPath.row];
    cell.contentView.backgroundColor = collection.averageColor;
    cell.mashupView.image = nil;
    
    if (collection.hasCoverImage) {
        
        cell.mashupView.alpha = 0;
        cell.mashupView.image = [collection coverImage];
        
        float millisecondsDelay = (arc4random() % 700) / 2000.0f;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, millisecondsDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:AlphaTransitionDuration animations:^{
                cell.mashupView.alpha = MashupAlpha;
            }];
        });

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
    
    if ([Helper isIPhoneDevice]) {
        return CGRectGetHeight(screen) / kRowsiPhonePortrait;
    } else {
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                return CGRectGetHeight(screen) / kRowsiPadPortrait;
            } else {
                return CGRectGetWidth(screen) / kRowsiPadLandscape;
            }
        }
        
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            return CGRectGetHeight(screen) / kRowsiPadPortrait;
        } else {
            return CGRectGetHeight(screen) / kRowsiPadLandscape;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = (CollectionViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.mashupView setAlpha:1.0];
    
    [[CollectionStore sharedStore] setCurrentCollection:[[CollectionStore sharedStore] collectionAtIndex:indexPath.row]];
    
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"collection_selection"
                                                           label:[CollectionStore sharedStore].currentCollection.collectionId
                                                           value:nil] build]];
    
    CollectionViewController *uvc = [CollectionViewController new];

    [[self navigationController] pushViewController:uvc animated:YES];
}


#pragma mark - LibraryOperationsDelegate

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths
{
    [tv reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

@end
