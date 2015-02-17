//
//  APIClient.h
//  Idiomics
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

typedef void (^SuccessHandler) (NSURLSessionDataTask *, id);
typedef void (^ErrorHandler) (NSURLSessionDataTask *, NSError *);

@interface APIClient : AFHTTPSessionManager

+ (instancetype)sharedConnection;

- (void)getAllCollectionWithSuccessHandler:(SuccessHandler)successHandler
                              errorHandler:(ErrorHandler)errorHandler;

- (void)getAllPanelForCollection:(NSString *)collectionId
                  successHandler:(SuccessHandler)successHandler
                    errorHandler:(ErrorHandler)errorHandler;

- (void)getAllPanelsWithSuccessHandler:(SuccessHandler)successHandler
                          errorHandler:(ErrorHandler)errorHandler;

- (void)getSingleBalloonPanelsWithSuccessHandler:(SuccessHandler)successHandler
                                    errorHandler:(ErrorHandler)errorHandler;

@end
