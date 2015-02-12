//
//  Panel.h
//  Idiomics
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mantle.h>

@interface Panel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *panelId;
@property (nonatomic, assign, readonly) CGSize dimensions;
@property (nonatomic, copy, readonly) NSString *imageUrl;
@property (nonatomic, copy, readonly) NSArray *balloons;
@property (nonatomic, copy, readonly) UIColor *averageColor;
@property (nonatomic, assign, readonly) BOOL hasThumbSizeImage;
@property (nonatomic, assign, readonly) BOOL hasFullSizeImage;
@property (nonatomic, getter = isFailed) BOOL failed;
@property (nonatomic, assign) CGSize thumbSize;

- (NSURLRequest *)buildUrlRequestForDimensions:(CGSize)dimensions;
- (UIImage *)thumbSizeImage;
- (UIImage *)fullSizeImage;

@end
