//
//  FocusOverlayView.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/30/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "FocusOverlayView.h"
#import <UIView+AutoLayout.h>

@implementation FocusOverlayView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        [self setAlpha:AlphaFocusBackground];
        
        UIImage *topLeft = [UIImage imageNamed:@"focus_corner_topleft.png"];
        UIImageView *topLeftView = [[UIImageView alloc] initWithImage:topLeft];
        [self addSubview:topLeftView];
        
        UIImage *topRight = [UIImage imageNamed:@"focus_corner_topright.png"];
        UIImageView *topRightView = [[UIImageView alloc] initWithImage:topRight];
        [self addSubview:topRightView];
        
        UIImage *bottomRight = [UIImage imageNamed:@"focus_corner_bottomright.png"];
        UIImageView *bottomRightView = [[UIImageView alloc] initWithImage:bottomRight];
        [self addSubview:bottomRightView];
        
        UIImage *bottomLeft = [UIImage imageNamed:@"focus_corner_bottomleft.png"];
        UIImageView *bottomLeftView = [[UIImageView alloc] initWithImage:bottomLeft];
        [self addSubview:bottomLeftView];
        
        [topLeftView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [topLeftView pinEdges:JRTViewPinTopEdge | JRTViewPinLeftEdge
            toSameEdgesOfView:self
                        inset:FocusInset];
        
        [topRightView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [topRightView pinEdges:JRTViewPinTopEdge | JRTViewPinRightEdge
             toSameEdgesOfView:self
                         inset:FocusInset];
        
        [bottomRightView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [bottomRightView pinEdges:JRTViewPinBottomEdge | JRTViewPinRightEdge
                toSameEdgesOfView:self
                            inset:FocusInset];
        
        [bottomLeftView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [bottomLeftView pinEdges:JRTViewPinBottomEdge | JRTViewPinLeftEdge
               toSameEdgesOfView:self
                           inset:FocusInset];
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



@end
