//
//  PanelImageStore.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PanelImageStoreDelegate <NSObject>

@optional

- (void)didLoadPanelWithPanelKey:(NSString *)key;
- (void)didLoadAllPanels;

@end

@interface PanelImageStore : NSObject
{
    NSMutableDictionary *panelImageDictionary;
}

@property (nonatomic, weak) id<PanelImageStoreDelegate> delegate;

+ (instancetype)sharedStore;
- (void)setAllPanelImages;
- (UIImage *)panelImageForKey:(NSString *)s;
- (void)addPanelImage:(UIImage *)panelImage forKey:(NSString *)key;
- (void)deletePanelImageForKey:(NSString *)s;
- (void)deletePanelImageDicitonary;

@end
