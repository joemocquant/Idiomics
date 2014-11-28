//
//  Config.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/13/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <UIKit/UIKit.h>

//MosaicLayout
#define kHeightModule 40

//MosaicCell
extern const CGFloat MosaicBorderWidth;
extern const NSTimeInterval AlphaTransitionDuration;
#define kImageViewMargin -5

//Transition
extern const NSTimeInterval TransitionDuration;

//Browser
extern NSString *const CellIdentifier;
extern CGFloat TimeDiff;
extern CGFloat ScrollSpeedThreshold;
extern CGFloat VelocityThreshold;
#define kDoubleColumnProbability 40
#define kColumnsiPadLandscape 4
#define kColumnsiPadPortrait 3
#define kColumnsiPhoneLandscape 3
#define kColumnsiPhonePortrait 2

//Panel
extern const CGFloat AlphaBackground;
extern const CGFloat MaxZoomScaleFactor;
extern const NSTimeInterval ZoomDuration;
extern const CGFloat ZoomScaleFactor;
extern const CGFloat Gutter;
extern const CGFloat ScaleFactor;

//MessageBar
extern const float MessageBarHeight;
extern const float NextButtonWidth;
extern const float MessageTextInset;
extern const float VerticalDashWidth;
extern const float HorizontalDashHeight;
