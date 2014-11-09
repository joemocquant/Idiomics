//
//  Panel.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/6/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Mantle.h>

@interface Panel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *panelId;
@property (nonatomic, assign, readonly) CGSize dimensions;
@property (nonatomic, copy, readonly) NSString *imageUrl;
@property (nonatomic, copy, readonly) NSArray *balloons;

@end
