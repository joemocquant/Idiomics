//
//  MosaicDataView.m
//  MosaicCollectionView
//
//  Created by Ezequiel A Becerra on 2/16/13.
//  Modified by Joe Mocquant on 11/23/14.
//  Copyright (c) 2013 Betzerra. All rights reserved.
//

#import "MosaicCell.h"
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking.h>
#import "PanelImageStore.h"
#import <UIView+AutoLayout.h>

#define kImageViewMargin -5

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
        self.layer.borderWidth = 0.8;
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
    [self setImage:nil];
}


#pragma mark - Private methods

- (void)setImage:(UIImage *)newImage
{
    self.imageView.image = newImage;
    
    if (self.mosaicData.firstTimeShown) {
        self.mosaicData.firstTimeShown = NO;
        
        self.imageView.alpha = 0.0;
        
        //  Random delay to avoid all animations happen at once
        float millisecondsDelay = (arc4random() % 700) / 2000.0f;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, millisecondsDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                self.imageView.alpha = 1.0;
            }];
        });
    }
}


#pragma mark - Getters/setters

- (void)setMosaicData:(MosaicData *)newMosaicData
{
    _mosaicData = newMosaicData;
    
    UIImage *cached = [[PanelImageStore sharedStore] panelImageForKey:self.mosaicData.imageId];
    
    if (!cached) {
        NSURL *anURL = [NSURL URLWithString:self.mosaicData.imageId];
        NSURLRequest *anURLRequest = [NSURLRequest requestWithURL:anURL];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:anURLRequest];
        [operation setResponseSerializer:[AFImageResponseSerializer serializer]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self setImage:responseObject];
            [[PanelImageStore sharedStore] addPanelImage:responseObject forKey:self.mosaicData.imageId];
            
        } failure:nil];
        
        [operation start];
        
    } else {
        [self setImage:cached];
    }
}

@end
