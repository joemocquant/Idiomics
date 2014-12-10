//
//  BalloonsOverlay.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/10/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "BalloonsOverlay.h"
#import "Fonts.h"
#import "Colors.h"
#import "FocusOverlayView.h"
#import "Balloon.h"
#import <UIView+AutoLayout.h>

@interface BalloonsOverlay ()

@property (nonatomic, readwrite, strong) NSMutableArray *speechBalloonsLabel;

@end

@implementation BalloonsOverlay

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (instancetype)initWithBalloons:(NSArray *)balloons
{
    self = [super init];
    
    if (self) {
    
        _speechBalloons = [NSMutableArray array];
        _speechBalloonsLabel = [NSMutableArray array];
        _focusOverlays = [NSMutableArray array];
        
        for (Balloon *balloon in balloons) {
            CGRect balloonRect = [balloon rect];
            
            UITextView *balloonTextView = [UITextView new];
            //UITextView
            [self addSubview:balloonTextView];
            
            //[balloonTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
            //[balloonTextView constrainToSize:balloonRect.size];
            
            //[balloonTextView pinEdges:JRTViewPinLeftEdge toSameEdgesOfView:panelImageView inset:balloonRect.origin.x];
            //[balloonTextView pinEdges:JRTViewPinTopEdge toSameEdgesOfView:panelImageView inset:balloonRect.origin.y];
            
            [balloonTextView setTextAlignment:NSTextAlignmentCenter];
            [balloonTextView setFont:[Fonts laffayetteComicPro30]];
            [balloonTextView setTextColor:[Colors gray5]];
            [balloonTextView setTintColor:[Colors gray5]];
            [balloonTextView setBackgroundColor:[Colors clear]];
            
            [balloonTextView setDelegate:self];
            
            //UILabel
            UILabel *balloonLabel = [UILabel new];
            [balloonLabel setAdjustsFontSizeToFitWidth:YES];
            //
            
            [_speechBalloons addObject:balloonTextView];
            
            FocusOverlayView *fov = [[FocusOverlayView alloc] init];
            [fov setFrame:balloonRect];
            [self addSubview:fov];
            [_focusOverlays addObject:fov];
            
            //UILabel
            [balloonLabel setAdjustsFontSizeToFitWidth:YES];
            [balloonLabel setNumberOfLines:0];
            [balloonLabel setFrame:balloonRect];
            [self addSubview:balloonLabel];
            [_speechBalloonsLabel addObject:balloonLabel];
            [balloonLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [balloonLabel constrainToSize:balloonRect.size];
            
            [balloonLabel pinEdges:JRTViewPinLeftEdge toSameEdgesOfView:self inset:balloonRect.origin.x];
            [balloonLabel pinEdges:JRTViewPinTopEdge toSameEdgesOfView:self inset:balloonRect.origin.y];
            [balloonLabel setTextAlignment:NSTextAlignmentCenter];
            [balloonLabel setFont:[Fonts laffayetteComicPro30]];
            [balloonLabel setTextColor:[Colors gray5]];
        }
    }
    
    return self;
}


#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSLog(@"a");
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"b");
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"range: %lu %lu with text <%@>", (unsigned long)range.location, (unsigned long)range.length, text);
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self.delegate balloonContentDidChangedWithText:textView.text];
}

@end
