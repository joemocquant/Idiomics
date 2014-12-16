//
//  UIColor+Tools.h
//  Idiomics
//
//  Created by Joe Mocquant on 12/14/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Tools)

+ (UIColor *)colorWithRGBString:(NSString *)color;
+ (NSString *)RGBStringFromColor:(UIColor *)color;
- (UIColor *)darkenColorWithPercentOfOriginal:(CGFloat)amount;

@end
