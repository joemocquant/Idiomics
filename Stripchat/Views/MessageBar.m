//
//  MessageBar.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/10/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "MessageBar.h"
#import "Colors.h"
#import "Fonts.h"
#import <UIView+AutoLayout.h>

@implementation MessageBar


#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    
    if (self) {

        [self setBackgroundColor:[Colors white]];
        [self setAlpha:0.85];
        
        CGRect screen = [[UIScreen mainScreen] bounds];
        CGRect frame = CGRectMake(0,0, CGRectGetWidth(screen), 60);
        [self setFrame:frame];
        
        [self setupSpeechTextView];
        [self setupButtonNext];
        [self setupHorizontalDash];
        [self setupVerticalDash];
    }
    
    return self;
}

- (void)setupSpeechTextView
{
    UITextView *speechTextField = [UITextView new];
    [speechTextField setDelegate:self];
    [speechTextField setBackgroundColor:[Colors clear]];
    [speechTextField setText:NSLocalizedStringFromTable(@"SPEECHPLACEHOLDER", @"Stripchat", nil)];
    [speechTextField setTextColor:[Colors gray4]];
    [speechTextField setFont:[Fonts helveticaNeueLight20]];
    speechTextField.returnKeyType = UIReturnKeyNext;
    
    [self addSubview:speechTextField];
    
    [speechTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [speechTextField pinEdges:JRTViewPinTopEdge | JRTViewPinBottomEdge toSameEdgesOfView:self];
    [speechTextField pinEdges:JRTViewPinLeftEdge toSameEdgesOfView:self inset:5];
    [speechTextField pinEdges:JRTViewPinRightEdge toSameEdgesOfView:self inset:80];
}

- (void)setupButtonNext
{
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setTitle:NSLocalizedStringFromTable(@"NEXTBUTTONTITLE", @"Stripchat", nil)
                forState:UIControlStateNormal];
    
    [[nextButton titleLabel] setFont:[Fonts helvetica20]];
    [nextButton setTitleColor:[Colors gray4] forState:UIControlStateNormal];
    UIColor *disabledColor = [[Colors gray4] colorWithAlphaComponent:0.5];
    [nextButton setTitleColor:disabledColor forState:UIControlStateDisabled];
    [nextButton setTitleColor:[Colors black] forState:UIControlStateHighlighted];
    [nextButton setBackgroundColor:[Colors black]];
    [nextButton setAlpha:0.8];
    [nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextButton];
    
    [nextButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [nextButton pinEdges:JRTViewPinTopEdge | JRTViewPinRightEdge | JRTViewPinBottomEdge
       toSameEdgesOfView:self];
    
    [nextButton constrainToWidth:80];
}

- (void)setupHorizontalDash
{
    UIView *horizontalDash = [UIView new];
    [horizontalDash setBackgroundColor:[Colors gray4]];
    [self addSubview:horizontalDash];
    
    CGFloat horizontalDashHeight = 2;
    
    [horizontalDash setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [horizontalDash pinEdges:JRTViewPinLeftEdge | JRTViewPinTopEdge | JRTViewPinRightEdge
           toSameEdgesOfView:self];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:horizontalDash
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:horizontalDashHeight]];
}

- (void)setupVerticalDash
{
    UIView *verticalDash = [UIView new];
    [verticalDash setBackgroundColor:[Colors gray4]];
    [verticalDash setAlpha:0.7];
    [self addSubview:verticalDash];
    
    CGFloat verticalDashWidth = 1;
    CGFloat verticalDashHeight = 1;
    
    [verticalDash setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [verticalDash pinAttribute:NSLayoutAttributeCenterY toSameAttributeOfItem:self];
    [verticalDash pinAttribute:NSLayoutAttributeRight toSameAttributeOfItem:self withConstant:-80];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:verticalDash
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:verticalDashWidth]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:verticalDash
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:verticalDashHeight
                                                      constant:0]];
}

- (void)next
{
    [self.delegate didPressNext];
}


#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self.delegate messageDidChange:textView.text];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    textView.text = @"";
    return YES;
}

@end
