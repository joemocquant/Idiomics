//
//  BalloonsOverlay.h
//  Idiomics
//
//  Created by Joe Mocquant on 12/10/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NavigationView;
@class Panel;

@interface BalloonsOverlay : UIView <UITextViewDelegate>
{
    NSMutableArray *overlays;
    NSMutableArray *speechBalloons;
    UIView *focusOverlaysView;
    BOOL panelEdited;
    NSMutableArray *balloonsEdited;
}

@property (nonatomic, readwrite, strong) NavigationView *navigationView;
@property (nonatomic, readonly, assign) NSInteger focus;

- (instancetype)initWithPanel:(Panel *)panel;
- (void)updateVisibilityWithNewFocus:(NSInteger)newFocus;
- (void)balloonsOverlayTappedOnce:(UIGestureRecognizer *)gestureRecognizer;
- (NSUInteger)charactersCount;

@end
