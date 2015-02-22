//
//  AppDelegate.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "AppDelegate.h"
#import "LibraryViewController.h"
#import "CollectionStore.h"
#import "Collection.h"
#import "CollectionViewController.h"
#import "APIClient.h"
#import "Helper.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <GAI.h>
#import <Instabug/Instabug.h>
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [Fabric with:@[CrashlyticsKit]];
    
    [Instabug startWithToken:@"3497581ae54156126c459f285585a7dd"
               captureSource:IBGCaptureSourceUIKit
             invocationEvent:IBGInvocationEventScreenshot];
    
    [Instabug setIsTrackingCrashes:NO];
    
    [Parse setApplicationId:@"FQW9xYrzMVm382ChHgZw7Cw60JiCawENF1zNrfZo"
                  clientKey:@"BbXkgpooMLLLAFVaod9sdZAqHDPk7qbtKDjGgzQ3"];
    
    // Register for Push Notitications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];

    
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:NSURLCacheMemoryCapacity
                                                            diskCapacity:NSURLCacheDiskCapacity
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    UIImage *imageNavBar = [UIImage imageNamed:@"navbar.png"];
    imageNavBar = [imageNavBar stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    [[UINavigationBar appearance] setBackgroundImage:imageNavBar forBarMetrics:UIBarMetricsDefault];
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;

    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [GAI sharedInstance].logger.logLevel = kGAILogLevelNone;
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-57412675-1"];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    // Override point for customization after application launch.
    
    [self loadAllCollections];
    
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //[PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
                
                [CollectionStore sharedStore].currentCollection = [[CollectionStore sharedStore] collectionAtIndex:0];
                
                LibraryViewController *lvc = [LibraryViewController new];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:lvc];
                
                CollectionViewController *uvc = [CollectionViewController new];
                [navController pushViewController:uvc animated:NO];
                
                self.window.rootViewController = navController;
                
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

@end
