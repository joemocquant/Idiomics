//
//  BalloonsOverlay.h
//  Idiomics
//
//  Created by Joe Mocquant on 12/10/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BalloonOverlayDelegate;

@interface BalloonsOverlay : UIView <UITextViewDelegate>

@property (nonatomic, readwrite, weak) id<BalloonOverlayDelegate> delegate;
@property (nonatomic, readonly, strong) NSMutableArray *focusOverlays;
@property (nonatomic, readonly, strong) NSMutableArray *speechBalloonsLabel;
@property (nonatomic, readonly, strong) NSMutableArray *speechBalloons;

- (instancetype)initWithBalloons:(NSArray *)balloons;

@end

@protocol BalloonOverlayDelegate <NSObject>

- (void)balloonContentDidChangedWithText:(NSString *)text;

@end