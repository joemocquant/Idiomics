//
//  UniverseViewCell.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/15/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "UniverseViewCell.h"
#import "Colors.h"
#import <UIView+AutoLayout.h>

@implementation UniverseViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setupImageView];
        [self setupSeparator];
    }

    return self;
}

- (void)setupImageView
{
    _imageCoverView = [UIImageView new];
    [_imageCoverView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.contentView addSubview:_imageCoverView];
    [_imageCoverView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_imageCoverView pinEdges:JRTViewPinAllEdges toSameEdgesOfView:self.contentView];
}

- (void)setupSeparator
{
    UIView *separator = [[UIView alloc] init];
    [separator setBackgroundColor:[Colors black]];
    
    [self.contentView addSubview:separator];
    [separator setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [separator pinEdges:JRTViewPinLeftEdge | JRTViewPinBottomEdge | JRTViewPinRightEdge
      toSameEdgesOfView:self];
    [separator constrainToHeight:SeparatorHeight];
}

@end
