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
        speechBalloonsLabel = [NSMutableArray array];
        overlays = [NSMutableArray array];
        balloonsEdited = [NSMutableArray array];
        
        for (Balloon *balloon in panel.balloons) {
            
            [balloonsEdited addObject:@NO];
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
            
            FocusOverlayView *fov = [[FocusOverlayView alloc] initWithBalloon:balloon color:panel.averageColor];
            [focusOverlaysView addSubview:fov];
            [overlays addObject:fov];
            
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

@end
