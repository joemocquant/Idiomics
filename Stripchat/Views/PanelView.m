//
//  PanelView.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/10/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "PanelView.h"
#import <UIView+AutoLayout.h>

@implementation PanelView


#pragma mark - Initialization

- (instancetype)initWithCell:(UIImageView *)civ
{
    self = [super init];
    
    if (self) {
        cellImageView = civ;
        [self setupPanelView];
    }
    
    return self;
}

- (UIScrollView *)panelScrollView
{
    return panelScrollView;
}

- (void)setupPanelView
{
    panelScrollView = [[UIScrollView alloc] init];
    [panelScrollView setDelegate:self];
    [panelScrollView setMinimumZoomScale:1.0];
    [panelScrollView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.8f]];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(PanelScrollViewTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    
    [panelScrollView addGestureRecognizer:singleTap];
    [panelScrollView setUserInteractionEnabled:YES];

    [self addSubview:panelScrollView];
    
    [panelScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [panelScrollView pinEdges:JRTViewPinAllEdges toSameEdgesOfView:self];
    
    panelImageView = [[UIImageView alloc] init];
    [panelImageView setImage:cellImageView.image];
    [panelImageView setContentMode:UIViewContentModeScaleAspectFit];
    [panelScrollView addSubview:panelImageView];
    
    [panelImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [panelImageView centerInView:panelScrollView];
    
    [panelScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[panelImageView]|"
                                                                            options:NSLayoutFormatAlignAllCenterY
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(panelImageView)]];
    
    [panelScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[panelImageView]|"
                                                                            options:NSLayoutFormatAlignAllCenterX
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(panelImageView)]];
}

- (void)PanelScrollViewTapped:(UIGestureRecognizer *)gestureRecognizer
{
    CGRect point = [panelScrollView convertRect:cellImageView.bounds fromView:cellImageView];
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         
                         [(UIImageView *)gestureRecognizer.view.subviews[0] setFrame:point];
                         
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}


#pragma mark - UIScrollViewDelegate

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return panelImageView;
}

@end
