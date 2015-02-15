//
//  UIImage+Tools.h
//  Idiomics
//
//  Created by Joe Mocquant on 2/15/15.
//  Copyright (c) 2015 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Tools)

- (UIImage *)addWatermark:(NSString *)watermark;
- (UIImage *)addGutterSize:(CGFloat)gutterSize;
- (UIImage *)resizeToRatio:(CGFloat)ratio;

@end
