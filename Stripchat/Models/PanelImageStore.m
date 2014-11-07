//
//  PanelImageStore.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "PanelImageStore.h"
#import "PanelStore.h"
#import "Panel.h"
#import <AFNetworking.h>
#import <ReactiveCocoa.h>

@implementation PanelImageStore


#pragma mark - Class methods

+ (instancetype)sharedStore
{
    static dispatch_once_t once;
    static id sharedStore;
    
    dispatch_once(&once, ^{
        
        if (!sharedStore) {
            sharedStore = [[self alloc] init];
        }
    });
    
    return sharedStore;
}


#pragma mark - Getters/setters

- (NSMutableDictionary *)panelImageDictionary
{
    if (!panelImageDictionary) {
        panelImageDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return panelImageDictionary;
}


#pragma mark - Instance methods

- (void)setAllPanelImages
{
    NSArray *requestOperations = [NSMutableArray array];

    requestOperations = [[[[[PanelStore sharedStore] allPanels] rac_sequence] map:^id(RACTuple *panelTuple) {
        
        Panel *panel = panelTuple.second;
        NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                              URLString:[panel.imageUrl absoluteString]
                                                                             parameters:nil
                                                                                  error:nil];
        
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [requestOperation setResponseSerializer:[AFImageResponseSerializer serializer]];

        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self.panelImageDictionary setValue:responseObject forKey:panel.panelId];
            [self.delegate didLoadPanelWithPanelId:panel.panelId];
        }
                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    
                                                    [self.panelImageDictionary setValue:panel forKey:panel.panelId];
                                                    [self.delegate didLoadPanelWithPanelId:panel.panelId];
                                                    
#ifdef __DEBUG__
                                                    NSLog(@"Panel Image loading error: %@", error);
#endif
                                                }];
        
        return requestOperation;
        
    }] array];
    
    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:requestOperations
                                                               progressBlock:^(NSUInteger numberOfFinishedOperations,
                                                                               NSUInteger totalNumberOfOperations) {
                                                                   
                                                               } completionBlock:^(NSArray *operations) {
                                                                   
#ifdef __DEBUG__
                                                                   NSLog(@"All panel images loaded!");
#endif
                                                               }];
    
    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
}

- (UIImage *)panelImageForKey:(NSString *)s
{
    return [self.panelImageDictionary objectForKey:s];
}

- (void)deletePanelImageForKey:(NSString *)s
{
    [self.panelImageDictionary removeObjectForKey:s];
}

- (void)deletePanelImageDicitonary
{
    [self.panelImageDictionary removeAllObjects];
}

@end
