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
#import "PanelImageStore.h"
#import <ReactiveCocoa.h>
#import <Mantle.h>

@interface BrowserViewController ()

@end

@implementation BrowserViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Stripchat";
    
    [[PanelImageStore sharedStore] setDelegate:self];
    [self loadAllPannels];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private methods

- (void)loadAllPannels
{
    SuccessHandler successHandler = ^(NSURLSessionDataTask *operation, id responseObject) {
        switch (((NSHTTPURLResponse *)[operation response]).statusCode) {
                
            case 200:
                //OK
            {
                NSArray *panels = [responseObject objectForKey:@"rows"];
                panels = [[[[panels valueForKey:@"value"] rac_sequence] map:^Panel *(id panel) {
                    
                    return [MTLJSONAdapter modelOfClass:Panel.class fromJSONDictionary:panel error:nil];
                    
                }] array];
                
                for (Panel *panel in panels) {
                    [[PanelStore sharedStore] addPanel:panel forKey:panel.panelId];
                }
                
                [[PanelImageStore sharedStore] setAllPanelImages];
                
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

- (void)didLoadPanelWithPanelId:(NSString *)panelId;
{
    NSLog(@"Panel id:%@ loaded", panelId);
}

@end
