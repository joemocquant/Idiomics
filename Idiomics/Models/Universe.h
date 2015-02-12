//
//  Universe.h
//  Idiomics
//
//  Created by Joe Mocquant on 12/14/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>

@class Panel;

@interface Universe : MTLModel <MTLJSONSerializing>
{
    NSMutableArray *allPanels;
}

@property (nonatomic, copy, readonly) NSString *universeId;
@property (nonatomic, copy, readonly) NSString *imageUrl;
@property (nonatomic, copy, readonly) UIColor *averageColor;
@property (nonatomic, assign, readonly) BOOL hasCoverImage;
@property (nonatomic, getter = isFailed) BOOL failed;

- (NSURLRequest *)buildUrlRequest;
- (NSMutableArray *)allPanels;
- (void)addPanel:(Panel *)panel;
- (Panel *)panelAtIndex:(NSUInteger)index;
- (void)deleteAllPanels;
- (UIImage *)coverImage;

@end
