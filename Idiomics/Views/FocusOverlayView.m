//
//  FocusOverlayView.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/30/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "FocusOverlayView.h"
#import "Balloon.h"
#import <UIView+AutoLayout.h>
#import <PulsingHaloLayer.h>

@implementation FocusOverlayView


#pragma  mark - Lifecycle

- (instancetype)initWithBalloon:(Balloon *)balloon color:(UIColor *)averageColor
{
    self = [super init];

    if (self) {

        [self setFrame:[balloon boundsRect]];
        
        UIBezierPath *polyPath = [UIBezierPath bezierPath];
        for (int i = 0; i < balloon.polygon.count; i++) {
            
            CGPoint point = [[balloon.polygon objectAtIndex:i] CGPointValue];
            
            if (i == 0) {
                [polyPath moveToPoint:CGPointMake(point.x - balloon.boundsRect.origin.x,
                                                  point.y - balloon.boundsRect.origin.y)];
            } else {
                [polyPath addLineToPoint:CGPointMake(point.x - balloon.boundsRect.origin.x,
                                                     point.y - balloon.boundsRect.origin.y)];
            } 
        }
        [polyPath closePath];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer new];
        [shapeLayer setPath:polyPath.CGPath];
        
        PulsingHaloLayer *halo = [PulsingHaloLayer layer];
        [halo setBackgroundColor:[UIColor whiteColor].CGColor];
        [halo setPosition:CGPointMake([balloon rect].origin.x - balloon.boundsRect.origin.x + [balloon rect].size.width / 2,
                                      [balloon rect].origin.y - balloon.boundsRect.origin.y + [balloon rect].size.height / 2)];
        
        [halo setKeyTimeForHalfOpacity:0.5];
        [halo setRadius:[self calculRadius]];
        [halo setBackgroundColor:[self calculHaloColorWithBalloonColor:[balloon backgroundColor]].CGColor];
        [self.layer addSublayer:halo];
        [self.layer setMask:shapeLayer];
    }

    return self;
}


#pragma mark - Getters/setters

- (void)setAlpha:(CGFloat)alpha
{
    [UIView animateWithDuration:NavigationControlDuration animations:^{
        [super setAlpha:alpha];
    }];
}

#pragma mark - Private methods

- (CGFloat)calculRadius
{
    CGFloat horizontalRadius = self.frame.size.width / 2;
    CGFloat verticalRadius = self.frame.size.height / 2;
    
    return MAX(horizontalRadius, verticalRadius);
}

- (UIColor *)calculHaloColorWithBalloonColor:(UIColor *)balloonColor
{
    float percentage = 75.0 / 100.0; //keep x% of original color
    long   totalComponents = CGColorGetNumberOfComponents(balloonColor.CGColor);
    bool  isGreyscale = totalComponents == 2 ? YES : NO;
    
    CGFloat* oldComponents = (CGFloat *)CGColorGetComponents(balloonColor.CGColor);
    CGFloat newComponents[4];
    
    if (isGreyscale) {
        newComponents[0] = oldComponents[0] * percentage;
        newComponents[1] = oldComponents[0] * percentage;
        newComponents[2] = oldComponents[0] * percentage;
        newComponents[3] = oldComponents[1];
    } else {
        newComponents[0] = oldComponents[0] * percentage;
        newComponents[1] = oldComponents[1] * percentage;
        newComponents[2] = oldComponents[2] * percentage;
        newComponents[3] = oldComponents[3];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *retColor = [UIColor colorWithCGColor:newColor];
    CGColorRelease(newColor);
    
    return retColor;
}

@end
