//
//  UIImage+Tools.m
//  Idiomics
//
//  Created by Joe Mocquant on 2/15/15.
//  Copyright (c) 2015 Idiomics. All rights reserved.
//

#import "UIImage+Tools.h"

@implementation UIImage (Tools)

- (UIImage *)addWatermark:(NSString *)watermark
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    UIImage *watermarkImage = [UIImage imageNamed:watermark];
    [watermarkImage drawInRect:CGRectMake(WatermarkOffset,
                                          self.size.height - watermarkImage.size.height - WatermarkOffset,
                                          watermarkImage.size.width,
                                          watermarkImage.size.height)
                     blendMode:kCGBlendModeNormal
                         alpha:WatermarkAlpha];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage *)addGutterSize:(CGFloat)gutterSize
{
    CGSize newSize = CGSizeMake(self.size.width + 2 * gutterSize, self.size.height + 2 * gutterSize);

    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    [self drawAtPoint:CGPointMake(gutterSize, gutterSize)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage *)resizeToRatio:(CGFloat)ratio
{
    CGSize imageSize = self.size;
    
    CGSize newSize;
    
    if ((imageSize.width / imageSize.height) > ratio) {
        newSize = CGSizeMake(imageSize.width, imageSize.width / ratio);
    } else if ((imageSize.height / imageSize.width) > ratio) {
        newSize = CGSizeMake(imageSize.height / ratio, imageSize.height);
    } else {
        newSize = CGSizeMake(imageSize.width, imageSize.height);
    }
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, (newSize.width - imageSize.width) / 2, (newSize.height - imageSize.height) / 2);
    
    [self drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

@end
