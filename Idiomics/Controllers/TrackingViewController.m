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
    
    NSString *name;
    
    if ([self isKindOfClass:BrowserViewController.class]) {
        name = @"browse";
    } else if ([self isKindOfClass:PanelViewController.class]) {
        name = @"panel_edition";
    }

    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:@"ui_action"
                                                         interval:@(elapsed)
                                                             name:name
                                                            label:nil] build]];
}

@end
