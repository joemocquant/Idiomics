//
//  ImageStore.h
//  Idiomics
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageStore : NSObject
{
    NSMutableDictionary *imageDictionary;
}

+ (instancetype)sharedStore;
- (UIImage *)panelThumbImageForKey:(NSString *)key;
- (void)addPanelThumbImage:(UIImage *)image forKey:(NSString *)key;
- (UIImage *)panelFullSizeImageForKey:(NSString *)key;
- (void)addPanelFullSizeImage:(UIImage *)image forKey:(NSString *)key;
- (UIImage *)universeImageForKey:(NSString *)key;
- (void)addUniverseImage:(UIImage *)image forKey:(NSString *)key;
- (void)deleteImagesForKey:(NSString *)key;
- (void)deleteImageDicitonary;

@end
