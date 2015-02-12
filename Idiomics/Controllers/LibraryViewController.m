//
//  LibraryViewController.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/15/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "LibraryViewController.h"
#import "UniverseViewController.h"
#import "APIClient.h"
#import "Helper.h"
#import "Colors.h"
#import "Universe.h"
#import "UniverseStore.h"
#import "UniverseViewCell.h"
#import <UIView+AutoLayout.h>
#import <GAI.h>
#import <GAIDictionaryBuilder.h>

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
    [tv registerClass:UniverseViewCell.class forCellReuseIdentifier:LibraryCellId];
    
    [self.view addSubview:tv];
    tv.translatesAutoresizingMaskIntoConstraints = NO;
    [tv pinEdges:JRTViewPinAllEdges toSameEdgesOfView:self.view];
    
    [self loadAllUniverses];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSIndexPath *selectedIndexPath = [tv indexPathForSelectedRow];
    UniverseViewCell *cell = (UniverseViewCell *)[tv cellForRowAtIndexPath:selectedIndexPath];
    cell.mashupView.alpha = MashupAlpha;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private methods

- (void)loadAllUniverses
{
    SuccessHandler successHandler = ^(NSURLSessionDataTask *operation, id responseObject) {
        switch (((NSHTTPURLResponse *)operation.response).statusCode) {
                
            case 200:
                //OK
            {
                NSArray *universes = [[responseObject objectForKey:@"rows"] valueForKey:@"value"];
                
                for (NSDictionary *universe in universes) {
                    
                    Universe *u = [MTLJSONAdapter modelOfClass:Universe.class fromJSONDictionary:universe error:nil];
                    [[UniverseStore sharedStore] addUniverse:u];
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
    
    [[APIClient sharedConnection] getAllUniverseWithSuccessHandler:successHandler
                                                      errorHandler:errorHandler];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[UniverseStore sharedStore] allUniverses].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UniverseViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LibraryCellId];

    if (cell == nil) {
        cell = [[UniverseViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:LibraryCellId];
    }
    
    Universe *universe = [[UniverseStore sharedStore] universeAtIndex:indexPath.row];
    cell.contentView.backgroundColor = universe.averageColor;
    cell.mashupView.image = nil;
    
    if (universe.hasCoverImage) {
        
        cell.mashupView.alpha = 0;
        cell.mashupView.image = [universe coverImage];
        
        float millisecondsDelay = (arc4random() % 700) / 2000.0f;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, millisecondsDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:AlphaTransitionDuration animations:^{
                cell.mashupView.alpha = MashupAlpha;
            }];
        });

    } else if (universe.isFailed) {
        
        
    } else {
        //if (!tv.dragging) {
            [libraryOperations startOperationsForUniverse:universe atIndexPath:indexPath];
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
    UniverseViewCell *cell = (UniverseViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.mashupView setAlpha:1.0];
    
    [[UniverseStore sharedStore] setCurrentUniverse:[[UniverseStore sharedStore] universeAtIndex:indexPath.row]];
    
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"universe_selection"
                                                           label:[UniverseStore sharedStore].currentUniverse.universeId
                                                           value:nil] build]];
    
    UniverseViewController *uvc = [UniverseViewController new];

    [[self navigationController] pushViewController:uvc animated:YES];
}


#pragma mark - LibraryOperationsDelegate

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths
{
    [tv reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

@end
