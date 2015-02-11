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
#import "Panel.h"
#import "Balloon.h"
#import "NavigationView.h"
#import "UITextView+VerticalAlignment.h"
#import <UIView+AutoLayout.h>

@interface BalloonsOverlay ()

@property (nonatomic, readwrite, assign) NSInteger focus;

@end

@implementation BalloonsOverlay


#pragma mark - Lifecycle

- (instancetype)initWithPanel:(Panel *)panel
{
    self = [super init];
    
    if (self) {
        
        _focus = -1;
        
        focusOverlaysView = [UIView new];
        [self addSubview:focusOverlaysView];
        [focusOverlaysView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [focusOverlaysView pinEdges:JRTViewPinAllEdges toSameEdgesOfView:self];
        
        speechBalloons = [NSMutableArray array];
        overlays = [NSMutableArray array];
        balloonsEdited = [NSMutableArray array];
        
        [panel.balloons enumerateObjectsUsingBlock:^(Balloon *balloon, NSUInteger idx, BOOL *stop) {
            
            FocusOverlayView *fov = [[FocusOverlayView alloc] initWithBalloon:balloon
                                                                        color:panel.averageColor];
            [focusOverlaysView addSubview:fov];
            [overlays addObject:fov];
            
            [balloonsEdited addObject:@NO];
            CGRect balloonRect = [balloon rect];
            
            UITextView *balloonTextView = [[UITextView alloc] initWithFrame:balloonRect];
            [self addSubview:balloonTextView];
            
            [balloonTextView setTextAlignment:NSTextAlignmentCenter];
            [balloonTextView setFont:[Fonts komikaDisplayForSize:balloonRect.size.height * 0.6]];
            [balloonTextView updateTextFontSize];
            [balloonTextView setTextColor:[Colors oldPaperBlack]];
            [balloonTextView setTintColor:[Colors oldPaperBlack]];
            [balloonTextView setBackgroundColor:[Colors clear]];
            [balloonTextView setDelegate:self];
            [balloonTextView setUserInteractionEnabled:NO];
            [balloonTextView setAutocorrectionType:UITextAutocorrectionTypeNo];
            [balloonTextView.textContainer setLineBreakMode:NSLineBreakByWordWrapping];
            [balloonTextView setScrollEnabled:NO];

            UIBezierPath *aPath = [UIBezierPath bezierPathWithRect:balloon.boundsRect];
            [aPath appendPath:fov.polyPath];

            //[[balloonTextView textContainer] setExclusionPaths:@[aPath]];
            [speechBalloons addObject:balloonTextView];
        }];
    }
    
    return self;
}


#pragma mark - Getters/setters

- (void)setNavigationView:(NavigationView *)navigationView
{
    _navigationView = navigationView;
    
    if (![speechBalloons count]) {
        panelEdited = YES;
    }
    
    [navigationView updateVisibilityWithEdited:panelEdited];
}


#pragma mark - Instance methods

- (void)updateVisibilityWithNewFocus:(NSInteger)newFocus
{
    [UIView animateWithDuration:NavigationControlDuration animations:^{
        
        if (newFocus == -1) {
     
            if (self.focus != -1) {
                
                if (![balloonsEdited[self.focus] boolValue]) {
                    [overlays[self.focus] setAlpha:1.0];
                }
                [speechBalloons[self.focus] resignFirstResponder];
                [speechBalloons[self.focus] setUserInteractionEnabled:NO];
            }

            self.focus = -1;
        
        } else {
    
            if (self.focus != newFocus) {
            
                if (self.focus != -1) {
                    
                    if (![balloonsEdited[self.focus] boolValue]) {
                        [overlays[self.focus] setAlpha:1.0];
                    }
                    //[self.speechBalloons[focus] resignFirstResponder];
                }
                [overlays[newFocus] setAlpha:0.0];
                [speechBalloons[newFocus] setUserInteractionEnabled:YES];
                [speechBalloons[newFocus] becomeFirstResponder];
            
                self.focus = newFocus;
            }
        }
    }];
}


#pragma mark - Gestures

- (void)balloonsOverlayTappedOnce:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self];
    __block BOOL foundNewBalloon = NO;
    __block NSInteger focus;
    
    [speechBalloons enumerateObjectsUsingBlock:^(UITextView *balloon, NSUInteger idx, BOOL *stop) {
        
        if (CGRectContainsPoint([balloon frame], location)) { //A balloon tapped
            focus = idx;
            
            if (self.focus == idx) { //Current balloon with focus
                *stop = YES;
            } else { //New balloon
                foundNewBalloon = YES;
            }
        }
    }];
    
    if (foundNewBalloon) {
        
        [self.navigationView updateVisibilityWithEdited:panelEdited];
        [self updateVisibilityWithNewFocus:focus];
        
    } else { //Other part was tapped
        if (self.focus != -1) { //during editing
            
            if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                [[self.navigationView cancel] sendActionsForControlEvents:UIControlEventTouchUpInside];
            } else {
                [self updateVisibilityWithNewFocus:-1];
            }
            
        } else { //during preview
            if (CGRectContainsPoint(self.frame, location)) { //in panel
                [self.navigationView toggleVisibilityWithEdited:panelEdited];
                
            } else { //outside
                [[self.navigationView cancel] sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}


#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSRange selectedRange = textView.selectedRange;
    textView.text = [textView.text uppercaseString];
    [textView setSelectedRange:selectedRange];
    
    [textView updateTextFontSize];
    
    if ([textView.text isEqualToString:@""]) {
        balloonsEdited[self.focus] = @NO;
        
        panelEdited = NO;
        [balloonsEdited enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj boolValue]) {
                panelEdited = YES;
                *stop = YES;
            }
        }];
        
    } else {
        balloonsEdited[self.focus] = @YES;
        panelEdited = YES;
    }
    
    [self.navigationView updateVisibilityWithEdited:panelEdited];
}

- (NSUInteger)charactersCount
{
    NSUInteger count = 0;
    for (UITextView *balloon in speechBalloons) {
        count += [balloon.text lengthOfBytesUsingEncoding:NSUTF32StringEncoding] / 4;
    }

    return count;
}

@end
