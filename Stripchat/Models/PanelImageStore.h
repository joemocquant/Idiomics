//
//  PanelImageStore.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PanelImageStore : NSObject
{
    NSMutableDictionary *panelImageDictionary;
}

+ (instancetype)sharedStore;
- (UIImage *)panelThumbImageForKey:(NSString *)s;
- (void)addPanelThumbImage:(UIImage *)panelImage forKey:(NSString *)key;
- (UIImage *)panelFullSizeImageForKey:(NSString *)s;
- (void)addPanelFullSizeImage:(UIImage *)panelImage forKey:(NSString *)key;
- (void)deletePanelImageForKey:(NSString *)s;
- (void)deletePanelImageDicitonary;

@end
