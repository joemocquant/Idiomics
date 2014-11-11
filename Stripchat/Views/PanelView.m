//
//  PanelView.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/10/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "PanelView.h"
#import "Colors.h"
#import "SpeechBar.h"
#import <UIView+AutoLayout.h>

@interface PanelView ()

// Override inputAccessoryView to readWrite
@property (nonatomic, readwrite, retain) UIView *inputAccessoryView;

@end

@implementation PanelView

- (bool) canBecomeFirstResponder {
    return true;
}

- (UIView *)inputAccessoryView {
    if(!_inputAccessoryView) {
        _inputAccessoryView = [[SpeechBar alloc] init];
    }
    return _inputAccessoryView;
}


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

- (void)setupPanelView
{
    panelScrollView = [[UIScrollView alloc] init];
    [panelScrollView setDelegate:self];
    [panelScrollView setMinimumZoomScale:1.0];
    [panelScrollView setBackgroundColor:[[Colors gray3] colorWithAlphaComponent:0.8f]];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(PanelScrollViewTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    
    [panelScrollView addGestureRecognizer:singleTap];
    [panelScrollView setUserInteractionEnabled:YES];

    [self addSubview:panelScrollView];
    
    [panelScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [panelScrollView pinEdges:JRTViewPinLeftEdge | JRTViewPinTopEdge | JRTViewPinRightEdge
            toSameEdgesOfView:self];
    [panelScrollView pinAttribute:NSLayoutAttributeBottom toSameAttributeOfItem:self withConstant:-60];
    
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
                         [self becomeFirstResponder];
                         [(UIImageView *)gestureRecognizer.view.subviews[0] setFrame:point];
                         
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}


#pragma mark - Instance methods

- (UIScrollView *)panelScrollView
{
    return panelScrollView;
}


#pragma mark - UIScrollViewDelegate

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return panelImageView;
}

@end
