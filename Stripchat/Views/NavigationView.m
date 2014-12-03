//
//  NavigationView.m
//  Stripchat
//
//  Created by Joe Mocquant on 12/2/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "NavigationView.h"
#import <UIView+AutoLayout.h>

@implementation NavigationView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self constrainToHeight:NavigationControlHeight];
        CGSize buttonSize = CGSizeMake(NavigationControlHeight, NavigationControlHeight);
        
        _cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancel setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        [self addSubview:_cancel];
        
        [_cancel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_cancel constrainToSize:buttonSize];
        [_cancel pinEdges:JRTViewPinLeftEdge | JRTViewPinBottomEdge toSameEdgesOfView:self];
        
        _send = [UIButton buttonWithType:UIButtonTypeCustom];
        [_send setImage:[UIImage imageNamed:@"send.png"] forState:UIControlStateNormal];
        [self addSubview:_send];
        
        [_send setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_send constrainToSize:buttonSize];
        [_send pinEdges:JRTViewPinRightEdge | JRTViewPinBottomEdge toSameEdgesOfView:self];
    }
    
    return self;
}

- (void)toggleVisibility
{
    [UIView animateWithDuration:NavigationControlDuration animations:^{

        if (self.alpha) {
            [self setAlpha:0.0];
        } else {
            if ([self isEdited]) {
                [self setAlpha:1.0];
            }
        }
    }];
}

- (void)updateVisibility
{
    if (!self.alpha && self.isEdited) {
        [self toggleVisibility];
    } else if (self.alpha && !self.isEdited) {
        [self toggleVisibility];
    }
}

@end
