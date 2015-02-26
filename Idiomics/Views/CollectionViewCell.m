//
//  CollectionViewCell.m
//  Idiomics
//
//  Created by Joe Mocquant on 12/15/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "CollectionViewCell.h"
#import "Colors.h"
#import <UIView+AutoLayout.h>

@implementation CollectionViewCell


#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {

        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupMashupScrollView];
        [self setupSeparators];
    }

    return self;
}

- (void)setupMashupScrollView
{
    UIScrollView *mashupScrollView = [[UIScrollView alloc] init];
    mashupScrollView.delegate = self;
    mashupScrollView.showsHorizontalScrollIndicator = NO;
    
    [self.contentView addSubview:mashupScrollView];
    mashupScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [mashupScrollView pinEdges:JRTViewPinAllEdges toSameEdgesOfView:self.contentView];
    
    mashupScrollView.userInteractionEnabled = NO;
    [self.contentView addGestureRecognizer:mashupScrollView.panGestureRecognizer];
    
    _mashupView = [UIImageView new];
    _mashupView.contentMode = UIViewContentModeScaleAspectFill;
    
    [mashupScrollView addSubview:_mashupView];
    _mashupView.translatesAutoresizingMaskIntoConstraints = NO;
    [_mashupView pinEdges:JRTViewPinAllEdges toSameEdgesOfView:mashupScrollView];
    
    _iconView = [UIImageView new];
    _iconView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView insertSubview:_iconView aboveSubview:_mashupView];
    
    _iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [_iconView pinAttribute:NSLayoutAttributeCenterX toAttribute:NSLayoutAttributeCenterX ofItem:self.contentView];
    [_iconView pinAttribute:NSLayoutAttributeCenterY toAttribute:NSLayoutAttributeCenterY ofItem:self.contentView];
    [_iconView constrainToSize:CGSizeMake(100, 100)];
}

- (void)setupSeparators
{
    UIView *separatorTop = [UIView new];
    separatorTop.backgroundColor = [Colors black];
    
    [self.contentView addSubview:separatorTop];
    separatorTop.translatesAutoresizingMaskIntoConstraints = NO;
    
    [separatorTop pinEdges:JRTViewPinLeftEdge | JRTViewPinTopEdge | JRTViewPinRightEdge
         toSameEdgesOfView:self.contentView];
    [separatorTop constrainToHeight:SeparatorHeight];
    
    UIView *separatorBottom = [UIView new];
    separatorBottom.backgroundColor = [Colors black];
    
    [self.contentView addSubview:separatorBottom];
    separatorBottom.translatesAutoresizingMaskIntoConstraints = NO;
    
    [separatorBottom pinEdges:JRTViewPinLeftEdge | JRTViewPinBottomEdge | JRTViewPinRightEdge
            toSameEdgesOfView:self.contentView];
    [separatorBottom constrainToHeight:SeparatorHeight];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        _mashupView.alpha = 1.0;
        _iconView.alpha = 0.0;
    } else {
       _mashupView.alpha = self.mashupAlpha;
        _iconView.alpha = 1.0;
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _mashupView.image = nil;
    _mashupView.alpha = 0;
    _iconView.image = nil;
    _iconView.alpha = 1.0;
}


#pragma mark - UIScrollviewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _mashupView.alpha = 1.0;
    _iconView.alpha = 0.0;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        _mashupView.alpha = self.mashupAlpha;
        _iconView.alpha = 1.0;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _mashupView.alpha = self.mashupAlpha;
    _iconView.alpha = 1.0;
}

@end
