//
//  MosaicDataView.m
//  MosaicCollectionView
//
//  Created by Ezequiel A Becerra on 2/16/13.
//  Copyright (c) 2013 Betzerra. All rights reserved.
//

#import "MosaicCell.h"
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking.h>
#import "PanelImageStore.h"

#define kLabelHeight 20
#define kLabelMargin 10
#define kImageViewMargin 0

@interface MosaicCell ()

- (void)setup;

@end

@implementation MosaicCell


#pragma mark - Private

- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
    
    //  Set image view
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    
    [self addSubview:_imageView];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_imageView
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1
                                                                       constant:kImageViewMargin];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:_imageView
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1
                                                                        constant:-kImageViewMargin];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_imageView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:kImageViewMargin];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_imageView
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1
                                                                         constant:-kImageViewMargin];
    
    NSArray *constraints = @[leftConstraint, rightConstraint, topConstraint, bottomConstraint];
    [self addConstraints:constraints];
    
    //  Added black stroke
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.clipsToBounds = YES;
}


#pragma mark - Properties

- (UIImage *)image
{
    return _imageView.image;
}

- (void)setImage:(UIImage *)newImage
{
    _imageView.image = newImage;
    
    if (_mosaicData.firstTimeShown) {
        _mosaicData.firstTimeShown = NO;
        
        _imageView.alpha = 0.0;
        
        //  Random delay to avoid all animations happen at once
        float millisecondsDelay = (arc4random() % 700) / 1000.0f;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, millisecondsDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                _imageView.alpha = 1.0;
            }];
        });        
    }
}

- (MosaicData *)mosaicData{
    return _mosaicData;
}

- (void)setHighlighted:(BOOL)highlighted
{
    //  This avoids the animation runs every time the cell is reused
    if (self.isHighlighted != highlighted){
        _imageView.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            _imageView.alpha = 1.0;
        }];        
    }
    
    [super setHighlighted:highlighted];
}

- (void)setMosaicData:(MosaicData *)newMosaicData
{
    _mosaicData = newMosaicData;
    
    UIImage *cached = [[PanelImageStore sharedStore] panelImageForKey:_mosaicData.imageFilename];
    
    if (!cached) {
        NSURL *anURL = [NSURL URLWithString:_mosaicData.imageFilename];
        NSURLRequest *anURLRequest = [NSURLRequest requestWithURL:anURL];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:anURLRequest];
        [operation setResponseSerializer:[AFImageResponseSerializer serializer]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //  This check is to avoid wrong images on reused cells
            if ([newMosaicData.title isEqualToString:_mosaicData.title]){
                self.image = responseObject;
                [[PanelImageStore sharedStore] addPanelImage:responseObject forKey:_mosaicData.imageFilename];
            }
            
        }
                                         failure:nil];
        
        [operation start];
        
    }else{
        self.image = cached;
    }
}


#pragma mark - Public

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self setup];
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
    self.image = nil;
}

- (UIImageView *)imageView
{
    return _imageView;
}

@end
