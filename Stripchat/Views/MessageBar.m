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
        
        CGRect screen = [[UIScreen mainScreen] bounds];
        CGRect frame = CGRectMake(0,0, CGRectGetWidth(screen), MessageBarHeight);
        [self setFrame:frame];
        
        [self setupMessageTextView];
        [self setupButtonNext];
        [self setupHorizontalDash];
        [self setupVerticalDash];
    }
    
    return self;
}

- (void)setupMessageTextView
{
    UITextView *messageTextField = [UITextView new];
    [messageTextField setDelegate:self];
    [messageTextField setText:NSLocalizedStringFromTable(@"MESSAGEPLACEHOLDER", @"Stripchat", nil)];
    [messageTextField setTextColor:[Colors gray4]];
    [messageTextField setFont:[Fonts helveticaNeueLight20]];
    messageTextField.returnKeyType = UIReturnKeyNext;
    [self addSubview:messageTextField];
    
    [messageTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [messageTextField pinEdges:JRTViewPinTopEdge | JRTViewPinBottomEdge toSameEdgesOfView:self];
    [messageTextField pinEdges:JRTViewPinLeftEdge toSameEdgesOfView:self inset:MessageTextInset];
    [messageTextField pinEdges:JRTViewPinRightEdge toSameEdgesOfView:self inset:NextButtonWidth];
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
    [nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextButton];
    
    [nextButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [nextButton pinEdges:JRTViewPinTopEdge | JRTViewPinRightEdge | JRTViewPinBottomEdge
       toSameEdgesOfView:self];
    [nextButton constrainToWidth:NextButtonWidth];
}

- (void)setupHorizontalDash
{
    UIView *horizontalDash = [UIView new];
    [horizontalDash setBackgroundColor:[Colors gray4]];
    [self addSubview:horizontalDash];
    
    [horizontalDash setTranslatesAutoresizingMaskIntoConstraints:NO];
    [horizontalDash pinEdges:JRTViewPinLeftEdge | JRTViewPinTopEdge | JRTViewPinRightEdge
           toSameEdgesOfView:self];
    [horizontalDash constrainToHeight:HorizontalDashHeight];
}

- (void)setupVerticalDash
{
    UIView *verticalDash = [UIView new];
    [verticalDash setBackgroundColor:[Colors gray4]];
    [self addSubview:verticalDash];
    
    [verticalDash setTranslatesAutoresizingMaskIntoConstraints:NO];
    [verticalDash pinAttribute:NSLayoutAttributeCenterY toSameAttributeOfItem:self];
    [verticalDash pinAttribute:NSLayoutAttributeRight toSameAttributeOfItem:self
                  withConstant:-NextButtonWidth];
    [verticalDash constrainToWidth:VerticalDashWidth];
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
