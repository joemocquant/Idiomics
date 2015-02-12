//
//  TrackingViewController.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/10/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "TrackingViewController.h"
#import "LibraryViewController.h"
#import "UniverseViewController.h"
#import "PanelViewController.h"
#import "Helper.h"
#import <GAI.h>
#import <GAIDictionaryBuilder.h>

@implementation TrackingViewController


#pragma mark - Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    trackingIntervalStart = [NSDate date];
    
    if ([self isKindOfClass:[LibraryViewController class]]) {
        self.screenName = @"library";
    } else if ([self isKindOfClass:[UniverseViewController class]]) {
        self.screenName = @"universe";
    } else if ([self isKindOfClass:[PanelViewController class]]) {
        self.screenName = @"panel_edition";
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSInteger elapsed = trackingIntervalStart.timeIntervalSinceNow * -1 * 1000;
    id tracker = [GAI sharedInstance].defaultTracker;
    
    if ([self isKindOfClass:LibraryViewController.class]) {
        [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:@"ui_time_spent"
                                                             interval:@(elapsed)
                                                                 name:@"library"
                                                                label:nil] build]];
    } else if ([self isKindOfClass:UniverseViewController.class]) {
        [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:@"ui_time_spent"
                                                             interval:@(elapsed)
                                                                 name:@"universe_browsing"
                                                                label:nil] build]];
        
    } else if ([self isKindOfClass:PanelViewController.class]) {
        [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:@"ui_time_spent"
                                                             interval:@(elapsed)
                                                                 name:@"panel_edition"
                                                                label:panelId] build]];
    }
}

@end
