//
//  ShareViewController.m
//  Idiomics
//
//  Created by Joe Mocquant on 2/14/15.
//  Copyright (c) 2015 Idiomics. All rights reserved.
//

#import "ShareViewController.h"
#import "PanelItemProvider.h"
#import "Panel.h"
#import "PanelViewController.h"
#import <extobjc.h>
#import <GAI.h>
#import <GAIDictionaryBuilder.h>
#import <GAIFields.h>

@implementation ShareViewController


#pragma mark - Lifecycle

- (instancetype)initWithPanel:(Panel *)p
                   imagePanel:(UIImage *)imagePanel
{
    PanelItemProvider *piv = [[PanelItemProvider alloc] initWithPlaceholderItem:imagePanel];
    
    self = [super initWithActivityItems:@[piv] applicationActivities:nil];
    
    if (self) {
        
        panel = p;
        
        //Default sharing:
        //UIActivityTypeMessage
        //UIActivityTypeMail
        //UIActivityTypePostToTwitter
        //UIActivityTypePostToFacebook
        
        self.excludedActivityTypes = @[UIActivityTypePrint,
                                       UIActivityTypeCopyToPasteboard,
                                       UIActivityTypeAssignToContact,
                                       UIActivityTypeSaveToCameraRoll,
                                       UIActivityTypeAddToReadingList,
                                       UIActivityTypePostToFlickr,
                                       UIActivityTypePostToVimeo,
                                       UIActivityTypeAirDrop];
    
    
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        
            @weakify(self)
            [self setCompletionWithItemsHandler:^(NSString *activityType,
                                                  BOOL completed,
                                                  NSArray *returnedItems,
                                                  NSError *activityError) {
            
                @strongify(self)
                [self trackSharingWithCompleted:completed activityType:activityType];
                
            }];
            
        } else {
            
            @weakify(self);
            [self setCompletionHandler:^(NSString *activityType, BOOL completed) {
            
                @strongify(self)
                [self trackSharingWithCompleted:completed activityType:activityType];
                
            }];
            
        }
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker set:kGAIScreenName value:@"share"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSInteger elapsed = trackingIntervalStart.timeIntervalSinceNow * -1 * 1000;
    
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:@"ui_time_spent"
                                                         interval:@(elapsed)
                                                             name:@"share"
                                                            label:panel.panelId] build]];
    
    [tracker set:kGAIScreenName value:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private methods

- (void)trackSharingWithCompleted:(BOOL)completed activityType:(NSString *)activityType
{
    id tracker = [GAI sharedInstance].defaultTracker;
    
    if (completed) {
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"share_success_panel"
                                                               label:panel.panelId
                                                               value:nil] build]];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"share_success_network"
                                                               label:activityType
                                                               value:nil] build]];
        
    } else {
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_error"
                                                              action:@"share_error_panel"
                                                               label:panel.panelId
                                                               value:nil] build]];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_error"
                                                              action:@"share_error_network"
                                                               label:activityType
                                                               value:nil] build]];
    }
}

@end
