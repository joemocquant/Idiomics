//
//  MosaicDataView.m
//  MosaicCollectionView
//
//  Created by Ezequiel A Becerra on 2/16/13.
//  Modified by Joe Mocquant on 11/23/14.
//  Copyright (c) 2013 Betzerra. All rights reserved.
//

#import "MosaicCell.h"
#import "MosaicData.h"
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking.h>
#import "PanelImageStore.h"
#import <UIView+AutoLayout.h>

@interface MosaicCell ()

@property (nonatomic, strong, readwrite) UIImageView *imageView;

@end

@implementation MosaicCell


#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        //Set image view
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        [_imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_imageView pinEdges:JRTViewPinAllEdges toSameEdgesOfView:self inset:kImageViewMargin];
        
        //Added black stroke
        self.layer.borderWidth = MosaicBorderWidth;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.clipsToBounds = YES;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
}


#pragma mark - Getters/setters

- (void)setMosaicData:(MosaicData *)newMosaicData
{
    _mosaicData = newMosaicData;
    
    UIImage *cached = [[PanelImageStore sharedStore] panelThumbImageForKey:self.mosaicData.imageId];
    self.imageView.image = cached;
    
    float millisecondsDelay;
    
    if (self.mosaicData.firstTimeShown) {
        self.mosaicData.firstTimeShown = NO;
        millisecondsDelay = (arc4random() % 700) / 2000.0f;
    } else {
        millisecondsDelay = (arc4random() % 700) / 4000.0f;
    }
    
    self.imageView.alpha = 0;
        
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, millisecondsDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:AlphaTransitionDuration animations:^{
            self.imageView.alpha = 1.0;
        }];
    });
}

@end
