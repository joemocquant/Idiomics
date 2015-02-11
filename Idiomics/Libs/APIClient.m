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
        [[self responseSerializer] setAcceptableContentTypes:[NSSet setWithObjects:@"application/json",
                                                                                   @"text/plain", nil]];
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
    @weakify(self)
    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        @strongify(self)
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            case AFNetworkReachabilityStatusNotReachable:
                [self.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
            case AFNetworkReachabilityStatusReachableViaWWAN:
            default:
                [self.requestSerializer setCachePolicy:APICachePolicy];
                break;
        }
        
    }];

    [self.reachabilityManager startMonitoring];
}

#pragma mark - Instance methods

- (void)getAllUniverseWithSuccessHandler:(SuccessHandler)successHandler
                            errorHandler:(ErrorHandler)errorHandler
{
    NSString *uri = @"content/_design/books/_view/all";
    [self GET:uri parameters:nil success:successHandler failure:errorHandler];
}

- (void)getAllPanelForUniverse:(NSString *)universeId
                successHandler:(SuccessHandler)successHandler
                  errorHandler:(ErrorHandler)errorHandler
{
    NSString *uri;
    NSDictionary *params = nil;
    
    if ([[self.baseURL absoluteString] isEqualToString:@"http://10.0.0.9:5984"]) {
        uri = @"content/_design/panels/_view/by_book";
        
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"\"%@\"", universeId], @"key",
                                nil];
    } else {
        uri = [NSString stringWithFormat:@"content/_design/panels/_view/by_book/%@", universeId];
    }
    
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
