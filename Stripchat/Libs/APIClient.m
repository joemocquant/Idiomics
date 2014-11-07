//
//  APIClient.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "APIClient.h"
#import "Helper.h"
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

#ifdef __DEBUG__
    #import <AFNetworkActivityLogger/AFNetworkActivityLogger.h>
#endif

@implementation APIClient


#pragma mark - Class methods

+ (instancetype)sharedConnection
{
    static dispatch_once_t once;
    static id sharedConnection;
    
    dispatch_once(&once, ^{
        
        if (!sharedConnection) {
            NSString *APIUrl = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Stripchat-API-URL"];
            sharedConnection = [[super alloc] initWithBaseURL:[NSURL URLWithString:APIUrl]];
        }
    });
    
    return sharedConnection;
}


#pragma mark - Private methods

//Designated Initializer
- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        [self setRequestSerializer:requestSerializer];
        [self setResponseSerializer:[AFJSONResponseSerializer serializer]];
        [[self responseSerializer] setAcceptableContentTypes:[NSSet setWithObjects:@"text/plain", nil]];
        
        [self startMonitoringAPI];
        
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        
#ifdef __DEBUG__
        [[AFNetworkActivityLogger sharedLogger] startLogging];
        [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
#endif
        
    }
    
    return self;
}

- (void)startMonitoringAPI
{
    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            case AFNetworkReachabilityStatusNotReachable:
                [Helper showErrorWithMsg:NSLocalizedStringFromTable(@"CONNECTION_ERROR", @"Stripchat" , nil)
                                delegate:nil];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
            case AFNetworkReachabilityStatusReachableViaWWAN:
                
                break;
            default:
                break;
        }
        
    }];
    
    [self.reachabilityManager startMonitoring];
}


#pragma mark - Instance methods

- (void)getAllPanelsWithSuccessHandler:(SuccessHandler)successHandler
                          errorHandler:(ErrorHandler)errorHandler
{
    [self GET:@"all" parameters:nil success:successHandler failure:errorHandler];
}

@end
