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
#import "NavigationView.h"
#import <UIView+AutoLayout.h>

@interface BalloonsOverlay ()

@property (nonatomic, readwrite, assign) NSInteger focus;

@end

@implementation BalloonsOverlay


#pragma mark - Lifecycle

- (instancetype)initWithBalloons:(NSArray *)balloons
{
    self = [super init];
    
    if (self) {
        
        _focus = -1;
        
        focusOverlayView = [UIView new];
        [self addSubview:focusOverlayView];
        [focusOverlayView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [focusOverlayView pinEdges:JRTViewPinAllEdges toSameEdgesOfView:self];
        
        speechBalloons = [NSMutableArray array];
        speechBalloonsLabel = [NSMutableArray array];
        focusOverlays = [NSMutableArray array];
        
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
            
            [speechBalloons addObject:balloonTextView];
            
            FocusOverlayView *fov = [[FocusOverlayView alloc] init];
            [fov setFrame:balloonRect];
            [focusOverlayView addSubview:fov];
            [focusOverlays addObject:fov];
            
            //UILabel
            [balloonLabel setAdjustsFontSizeToFitWidth:YES];
            [balloonLabel setNumberOfLines:0];
            [balloonLabel setFrame:balloonRect];
            [self addSubview:balloonLabel];
            [speechBalloonsLabel addObject:balloonLabel];
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


#pragma mark - Getters/setters

- (void)setNavigationView:(NavigationView *)navigationView
{
    _navigationView = navigationView;
    
    if (![speechBalloonsLabel count]) {
        edited = YES;
    }
    
    [navigationView updateVisibilityWithEdited:edited];
}


#pragma mark - Instance methods

- (void)updateVisibilityWithNewFocus:(NSInteger)newFocus
{
    [UIView animateWithDuration:NavigationControlDuration animations:^{
        
        if (newFocus == -1) {
     
            if (self.focus != -1) {
                [focusOverlays[self.focus] setAlpha:AlphaFocusBackground];
                [speechBalloons[self.focus] resignFirstResponder];
            }
        
            if (focusOverlayView.alpha == 0.0) {
                [focusOverlayView setAlpha:1.0];
            }
        
            self.focus = -1;
        
        } else {
    
            if (self.focus != newFocus) {
            
                if (self.focus != -1) {
                    [focusOverlays[self.focus] setAlpha:AlphaFocusBackground];
                    //[self.speechBalloons[focus] resignFirstResponder];
                }
                [focusOverlays[newFocus] setAlpha:AlphaFocusForeground];
                [speechBalloons[newFocus] becomeFirstResponder];
            
                self.focus = newFocus;
            }
        }
    }];
}

-(void)hideFocusOverlayView
{
    [focusOverlayView setAlpha:0.0];
}

- (void)toogleVisibility
{
    if ((self.navigationView.alpha) && (edited)) {
        
        [UIView animateWithDuration:NavigationControlDuration animations:^{
            [focusOverlayView setAlpha:0.0];
        }];
        
    } else {
        
        [self updateVisibilityWithNewFocus:-1];
    }
}


#pragma mark - Gestures

- (void)balloonsOverlayTappedOnce:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self];
    __block BOOL foundNewBalloon = NO;
    __block NSInteger focus;
    
    [speechBalloonsLabel enumerateObjectsUsingBlock:^(UILabel *balloon, NSUInteger idx, BOOL *stop) {
        
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
        
        [self.navigationView updateVisibilityWithEdited:edited];
        [self updateVisibilityWithNewFocus:focus];
        
    } else { //Other part was tapped
        if (self.focus != -1) { //during editing
            
            [self toogleVisibility];
            [self updateVisibilityWithNewFocus:-1];
            
        } else { //during preview
            if (CGRectContainsPoint(self.frame, location)) { //in panel
                [self.navigationView toggleVisibilityWithEdited:edited];
                [self toogleVisibility];
                
            } else { //outside
                [[self.navigationView cancel] sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
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
    UILabel *currentLabel = speechBalloonsLabel[self.focus];
    [currentLabel setText:textView.text];
    
    edited = NO;
    [speechBalloonsLabel enumerateObjectsUsingBlock:^(UILabel *obj, NSUInteger idx, BOOL *stop) {
        if (obj.text && ![obj.text isEqualToString:@""]) {
            edited = YES;
            *stop = YES;
        }
    }];
    
    [self.navigationView updateVisibilityWithEdited:edited];
}

@end
