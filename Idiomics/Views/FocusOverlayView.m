//
//  FocusOverlayView.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/30/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "FocusOverlayView.h"
#import "Balloon.h"
#import "UIColor+Tools.h"
#import <UIView+AutoLayout.h>
#import <PulsingHaloLayer.h>

@implementation FocusOverlayView


#pragma  mark - Lifecycle

- (instancetype)initWithBalloon:(Balloon *)balloon color:(UIColor *)averageColor
{
    self = [super init];

    if (self) {

        self.frame = balloon.outsideRect;
        
        _polyPath = [UIBezierPath bezierPath];
        for (int i = 0; i < balloon.polygon.count; i++) {
            
            CGPoint point = [[balloon.polygon objectAtIndex:i] CGPointValue];
            
            if (i == 0) {
                [self.polyPath moveToPoint:CGPointMake(point.x - balloon.outsideRect.origin.x,
                                                       point.y - balloon.outsideRect.origin.y)];
            } else {
                [_polyPath addLineToPoint:CGPointMake(point.x - balloon.outsideRect.origin.x,
                                                      point.y - balloon.outsideRect.origin.y)];
            } 
        }
        [_polyPath closePath];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer new];
        shapeLayer.path = _polyPath.CGPath;
        
        PulsingHaloLayer *halo = PulsingHaloLayer.layer;

        [halo setPosition:CGPointMake(balloon.insideRect.origin.x - balloon.outsideRect.origin.x + balloon.insideRect.size.width / 2,
                                      balloon.insideRect.origin.y - balloon.outsideRect.origin.y + balloon.insideRect.size.height / 2)];
        
        halo.backgroundColor = [balloon.backgroundColor darkenColorWithPercentOfOriginal:PercentColorKept].CGColor;
        
        halo.keyTimeForHalfOpacity = KeyTimeForHalfOpacity;
        halo.radius = [self calculRadius];
        [self.layer addSublayer:halo];
        self.layer.mask = shapeLayer;
    }

    return self;
}


#pragma mark - Getters/setters

- (void)setAlpha:(CGFloat)alpha
{
    [UIView animateWithDuration:NavigationControlDuration animations:^{
        super.alpha = alpha;
    }];
}

#pragma mark - Private methods

- (CGFloat)calculRadius
{
    CGFloat horizontalRadius = self.frame.size.width / 2;
    CGFloat verticalRadius = self.frame.size.height / 2;
    
    return MAX(horizontalRadius, verticalRadius);
}

@end
