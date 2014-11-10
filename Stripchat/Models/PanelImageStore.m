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
    NSMutableArray *requestOperations = [NSMutableArray array];
    
    for (Panel *panel in [[PanelStore sharedStore] allPanels]) {
        
        NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                              URLString:panel.imageUrl
                                                                             parameters:nil
                                                                                  error:nil];
        
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [requestOperation setResponseSerializer:[AFImageResponseSerializer serializer]];

        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self addPanelImage:responseObject forKey:panel.imageUrl];
            [self.delegate didLoadPanelWithPanelKey:panel.imageUrl];
        }
                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    
                                                    [self addPanelImage:nil forKey:panel.imageUrl];
                                                    [self.delegate didLoadPanelWithPanelKey:panel.imageUrl];
                                                }];
        
     
        [requestOperations addObject:requestOperation];
    };
    
    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:requestOperations
                                                               progressBlock:^(NSUInteger numberOfFinishedOperations,
                                                                               NSUInteger totalNumberOfOperations) {
                                                                   
                                                               } completionBlock:^(NSArray *operations) {
                                                                   
                                                                   [self.delegate didLoadAllPanels];
                                                               }];
    
    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
}

- (UIImage *)panelImageForKey:(NSString *)s
{
    return [self.panelImageDictionary objectForKey:s];
}

- (void)addPanelImage:(UIImage *)panelImage forKey:(NSString *)key
{
    [self.panelImageDictionary setValue:panelImage forKey:key];
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
