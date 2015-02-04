//
//  FocusOverlayView.h
//  Idiomics
//
//  Created by Joe Mocquant on 11/30/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Balloon;

@interface FocusOverlayView : UIView

@property (nonatomic, readonly, strong) UIBezierPath *polyPath;

- (instancetype)initWithBalloon:(Balloon *)balloon color:(UIColor *)averageColor;

@end
