//
//  APIClient.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

typedef void (^SuccessHandler) (NSURLSessionDataTask *, id);
typedef void (^ErrorHandler) (NSURLSessionDataTask *, NSError *);

@interface APIClient : AFHTTPSessionManager

+ (instancetype)sharedConnection;

- (void)getAllPanelsWithSuccessHandler:(SuccessHandler)successHandler
                          errorHandler:(ErrorHandler)errorHandler;

@end
