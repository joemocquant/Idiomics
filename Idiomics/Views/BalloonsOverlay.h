//
//  BalloonsOverlay.h
//  Idiomics
//
//  Created by Joe Mocquant on 12/10/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NavigationView;

@interface BalloonsOverlay : UIView <UITextViewDelegate>
{
    NSMutableArray *focusOverlays;
    NSMutableArray *speechBalloonsLabel;
    NSMutableArray *speechBalloons;
    UIView *focusOverlayView;
    BOOL edited;
}

@property (nonatomic, readwrite, strong) NavigationView *navigationView;
@property (nonatomic, readonly, assign) NSInteger focus;

- (instancetype)initWithBalloons:(NSArray *)balloons;
- (void)updateVisibilityWithNewFocus:(NSInteger)newFocus;
- (void)toogleVisibility;
- (void)balloonsOverlayTappedOnce:(UIGestureRecognizer *)gestureRecognizer;
- (void)hideFocusOverlayView;

@end
