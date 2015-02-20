//
//  APIClient.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "APIClient.h"
#import "Helper.h"
#import <extobjc.h>
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
            NSString *APIUrl = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Idiomics-API-URL"];
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
        
        [self.requestSerializer setCachePolicy:APICachePolicy];
        [self setResponseSerializer:[AFJSONResponseSerializer serializer]];
        [self responseSerializer].acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                                                 @"text/plain", nil];
        [self startMonitoringAPI];

        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
#ifdef __DEBUG__
        [[AFNetworkActivityLogger sharedLogger] startLogging];
        [AFNetworkActivityLogger sharedLogger].level = AFLoggerLevelDebug;
#endif
        
    }
    
    return self;
}

- (void)startMonitoringAPI
{
    @weakify(self)
    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        @strongify(self)
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            case AFNetworkReachabilityStatusNotReachable:
                self.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
            case AFNetworkReachabilityStatusReachableViaWWAN:
            default:
                self.requestSerializer.cachePolicy = APICachePolicy;
                break;
        }
        
    }];

    [self.reachabilityManager startMonitoring];
}

#pragma mark - Instance methods

- (void)getAllCollectionWithSuccessHandler:(SuccessHandler)successHandler
                              errorHandler:(ErrorHandler)errorHandler
{
    NSString *uri = @"collections";
    [self GET:uri parameters:nil success:successHandler failure:errorHandler];
}

- (void)getAllPanelForCollection:(NSString *)collectionId
                  successHandler:(SuccessHandler)successHandler
                    errorHandler:(ErrorHandler)errorHandler
{
    NSString *uri = @"panels";
//    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//                            [NSString stringWithFormat:@"\"%@\"", collectionId], @"key",
//                            nil];
//    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            collectionId, @"collection_id",
                            nil];
    
    [self GET:uri parameters:params success:successHandler failure:errorHandler];
}

- (void)getAllPanelsWithSuccessHandler:(SuccessHandler)successHandler
                          errorHandler:(ErrorHandler)errorHandler
{
    NSString *uri = @"content/_design/panels/_view/all";
    [self GET:uri parameters:nil success:successHandler failure:errorHandler];
}

- (void)getSingleBalloonPanelsWithSuccessHandler:(SuccessHandler)successHandler
                                    errorHandler:(ErrorHandler)errorHandler
{
    NSString *uri = @"content/_design/panels/_view/up_to_one_balloon";
    [self GET:uri parameters:nil success:successHandler failure:errorHandler];
}

@end
