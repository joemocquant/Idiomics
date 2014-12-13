//
//  TrackingViewController.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/10/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "TrackingViewController.h"
#import "BrowserViewController.h"
#import "PanelViewController.h"
#import "Helper.h"
#import <GAI.h>
#import <GAIDictionaryBuilder.h>

@implementation TrackingViewController


#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    trackingIntervalStart = [NSDate date];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSTimeInterval elapsed = [trackingIntervalStart timeIntervalSinceNow] * -1 * 1000;
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if ([self isKindOfClass:BrowserViewController.class]) {
        [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:@"ui_time_spent"
                                                             interval:@(elapsed)
                                                                 name:@"browse"
                                                                label:nil] build]];
        
    } else if ([self isKindOfClass:PanelViewController.class]) {
        [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:@"ui_time_spent"
                                                             interval:@(elapsed)
                                                                 name:@"panel_edition"
                                                                label:panelId] build]];
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([Helper isIPhoneDevice]) {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}

@end
