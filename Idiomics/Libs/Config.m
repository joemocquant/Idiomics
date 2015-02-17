//
//  Config.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/13/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "Config.h"

//MosaicCell
const CGFloat MosaicBorderWidth = 0.8;
const NSTimeInterval AlphaTransitionDuration = 0.2;

//Transition
const NSTimeInterval TransitionDuration = 0.2;

//Library
NSString *const LibraryCellId = @"LibraryCellId";
CGFloat SeparatorHeight = 2;
CGFloat MashupAlpha = 0.3;

//Collection
NSString *const CellIdentifier = @"cell";
CGFloat TimeDiff = 0.1;
CGFloat DistanceMin = 20;
CGFloat ScrollSpeedThreshold = 1.0;
CGFloat VelocityThreshold = 3.0;
CGFloat RelativeHeightRandomModifier = 0.25;

//Panel
const CGFloat AlphaBackground = 0.85;
const CGFloat MaxZoomScaleFactor = 4.0;
const NSTimeInterval ZoomDuration = 0.2;
const CGFloat ZoomScaleFactor = 3.0;
const CGFloat Gutter = 7.0;
const CGFloat GutterOpacity = 1.0;
const CGFloat GutterRadius = 0.8;
const CGFloat GutterShadowOffset = 2;
const CGFloat ScaleFactor = 0.85;
const CGFloat KeyboardMoveDuration = 0.4;
const CGFloat ScrollToBottomDuration = 0.2;
const CGFloat FocusMoveMargin = 50.0;
const CGFloat NavigationControlHeight = 60.0;
const CGFloat NavigationControlDuration = 0.4;
const CGFloat MenuMoveDuration = 0.6;
const CGFloat WatermarkOffset = 12.0;
const CGFloat WatermarkAlpha = 0.75;

//Transformers
NSString *const ColorTransformerName = @"ColorTransformer";
NSString *const RectTransformerName = @"RectTransformer";

//PulsingHalo
CGFloat PercentColorKept = 75.0;
CGFloat KeyTimeForHalfOpacity = 0.5;

//Cache
NSURLRequestCachePolicy APICachePolicy = NSURLRequestUseProtocolCachePolicy;
NSURLRequestCachePolicy LibraryCachePolicy = NSURLRequestUseProtocolCachePolicy;
NSURLRequestCachePolicy PanelCachePolicy = NSURLRequestUseProtocolCachePolicy;
NSTimeInterval TimeoutInterval = 60;
NSUInteger NSURLCacheMemoryCapacity = 2; //20 * 1024 * 1024; //Default is 512000
NSUInteger NSURLCacheDiskCapacity = 250 * 1024 * 1024; //Default is 10000000
CGFloat ThresholdResolution = 0.8;