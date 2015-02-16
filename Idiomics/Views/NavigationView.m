//
//  NavigationView.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/2/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "NavigationView.h"
#import <UIView+AutoLayout.h>

@implementation NavigationView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        CGSize buttonSize = CGSizeMake(NavigationControlHeight, NavigationControlHeight);
        
        _cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancel setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        [self addSubview:_cancel];
        
        _cancel.translatesAutoresizingMaskIntoConstraints = NO;
        [_cancel constrainToSize:buttonSize];
        [_cancel pinEdges:JRTViewPinLeftEdge | JRTViewPinBottomEdge toSameEdgesOfView:self];
        
        _send = [UIButton buttonWithType:UIButtonTypeCustom];
        [_send setImage:[UIImage imageNamed:@"send.png"] forState:UIControlStateNormal];
        [self addSubview:_send];
        
        _send.translatesAutoresizingMaskIntoConstraints = NO;
        [_send constrainToSize:buttonSize];
        [_send pinEdges:JRTViewPinRightEdge | JRTViewPinBottomEdge toSameEdgesOfView:self];
    }
    
    return self;
}

- (void)toggleVisibilityWithEdited:(BOOL)edited
{
    [UIView animateWithDuration:NavigationControlDuration animations:^{
        
        if (self.alpha) {
            super.alpha = 0.0;
            self.share.alpha = 0.0;
        } else {
            if (edited) {
                super.alpha = 1.0;
                self.share.alpha = 1.0;
            }
        }
    }];
}

- (void)updateVisibilityWithEdited:(BOOL)edited
{
    if (!self.alpha && edited) {
        [self toggleVisibilityWithEdited:edited];
    } else if (self.alpha && !edited) {
        [self toggleVisibilityWithEdited:edited];
    }
}

//Avoid iOS to change Alpha during rotation or other events
- (void)setAlpha:(CGFloat)alpha
{
}

@end
