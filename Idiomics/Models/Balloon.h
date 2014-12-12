//
//  Balloon.h
//  Idiomics
//
//  Created by Joe Mocquant on 12/1/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mantle.h>

@interface Balloon : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) UIColor *backgroundColor;
@property (nonatomic, assign, readonly) CGRect rect;
@property (nonatomic, assign, readonly) CGRect boundsRect;
@property (nonatomic, copy, readonly) NSArray *polygon;
@property (nonatomic, readwrite, assign) BOOL edited;

@end
