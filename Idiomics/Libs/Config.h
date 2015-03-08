//
//  Config.h
//  Idiomics
//
//  Created by Joe Mocquant on 11/13/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
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

//Library
extern NSString *const LibraryCellId;
extern CGFloat SeparatorHeight;
extern CGFloat MashupAlpha;
extern CGFloat MashupAlphaAll;
#define kRowsiPhonePortrait 4
#define kRowsiPadPortrait 4
#define kRowsiPadLandscape 3
#define kMashupRatio 4.5

//Collection
extern NSString *const CellIdentifier;
extern CGFloat TimeDiff;
extern CGFloat DistanceMin;
extern CGFloat ScrollSpeedThreshold;
extern CGFloat VelocityThreshold;
extern CGFloat RelativeHeightRandomModifier;
extern CGFloat CollectionAllRatio;
#define kDoubleColumnProbability 40
#define kColumnsiPhonePortrait 2
#define kColumnsiPadPortrait 3
#define kColumnsiPadLandscape 4

//Panel
extern const CGFloat AlphaBackground;
extern const CGFloat MaxZoomScaleFactor;
extern const NSTimeInterval ZoomDuration;
extern const CGFloat ZoomScaleFactor;
extern const CGFloat Gutter;
extern const CGFloat GutterOpacity;
extern const CGFloat GutterRadius;
extern const CGFloat GutterShadowOffset;
extern const CGFloat ScaleFactor;
extern const CGFloat KeyboardMoveDuration;
extern const CGFloat ScrollToBottomDuration;
extern const CGFloat FocusMoveMargin;
extern const CGFloat NavigationControlHeight;
extern const CGFloat NavigationControlDuration;
extern const CGFloat MenuMoveDuration;
extern const CGFloat WatermarkOffset;
extern const CGFloat WatermarkAlpha;


//Transformers
extern NSString *const ColorTransformerName;
extern NSString *const RectTransformerName;

//PulsingHalo
extern CGFloat PercentColorKept;
extern CGFloat KeyTimeForHalfOpacity;

//Cache
extern NSURLRequestCachePolicy APICachePolicy;
extern NSURLRequestCachePolicy LibraryCachePolicy;
extern NSURLRequestCachePolicy PanelCachePolicy;
extern NSTimeInterval TimeoutInterval;
extern NSUInteger NSURLCacheMemoryCapacity;
extern NSUInteger NSURLCacheDiskCapacity;
extern CGFloat ThresholdResolution;

//Versions
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)