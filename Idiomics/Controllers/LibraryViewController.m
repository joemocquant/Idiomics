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
#import "ImageStore.h"
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
    
    [self.navigationController setNavigationBarHidden:YES];
 
    libraryOperations = [LibraryOperations new];
    [libraryOperations setDelegate:self];
    
    tv = [UITableView new];
    [tv setDelegate:self];
    [tv setDataSource:self];
    [tv setBackgroundColor:[Colors black]];
    [tv setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tv registerClass:[UniverseViewCell class] forCellReuseIdentifier:LibraryCellId];
    
    [self.view addSubview:tv];
    [tv setTranslatesAutoresizingMaskIntoConstraints:NO];
    [tv pinEdges:JRTViewPinAllEdges toSameEdgesOfView:self.view];
    
    [self loadAllUniverses];
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
        switch (((NSHTTPURLResponse *)[operation response]).statusCode) {
                
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
    
    [[APIClient sharedConnection] getAllUniverseWithSuccessHandler:successHandler
                                                      errorHandler:errorHandler];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[UniverseStore sharedStore] allUniverses] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UniverseViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LibraryCellId];

    if (cell == nil) {
        cell = [[UniverseViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:LibraryCellId];
    }
    
    Universe *universe = [[UniverseStore sharedStore] universeAtIndex:indexPath.row];
    [cell.contentView setBackgroundColor:universe.averageColor];
    
    if ([universe hasCoverImage]) {
        [cell.imageCoverView setImage:[[ImageStore sharedStore] universeImageForKey:universe.imageUrl]];
        
    } else if ([universe isFailed]) {
        
        
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
    NSUInteger retVal;
 
    CGRect screen = [[UIScreen mainScreen] bounds];
    
    if ([Helper isIPhoneDevice]) {
        retVal = screen.size.height / 4;
    } else {
        
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            retVal = screen.size.height / 3;
        } else {
            retVal = screen.size.height / 4;
        }
    }
    
    return retVal;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[UniverseStore sharedStore] setCurrentUniverse:[[UniverseStore sharedStore] universeAtIndex:indexPath.row]];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"universe_selection"
                                                           label:[UniverseStore sharedStore].currentUniverse.universeId
                                                           value:nil] build]];
    
    UniverseViewController *uvc = [UniverseViewController new];
    [[self navigationController] pushViewController:uvc animated:YES];
}


#pragma mark - Rotation

- (NSUInteger)supportedInterfaceOrientations
{
    if ([Helper isIPhoneDevice]) {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}


#pragma mark - LibraryOperationsDelegate

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths
{
    [tv reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}


@end