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
#import "Panel.h"
#import <QuartzCore/QuartzCore.h>
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
        [self addSubview:_imageView];

        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
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

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (self.mosaicData.panel.hasFullSizeImage) {
        
        _imageView.alpha = 0.0;
        [UIView animateWithDuration:AlphaTransitionDuration * 2 animations:^{
            _imageView.alpha = 1.0;
        }];
    }
}

#pragma mark - Getters/setters

- (void)setMosaicData:(MosaicData *)newMosaicData
{
    _mosaicData = newMosaicData;
    
    self.imageView.image = [self.mosaicData.panel thumbSizeImage];
    
    float millisecondsDelay;
    
    if (self.mosaicData.firstTimeShown) {
        self.mosaicData.firstTimeShown = NO;
        millisecondsDelay = (arc4random() % 700) / 1000.0f;
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
