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
    
    _mashupView.alpha = MashupAlpha;
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


#pragma mark - UIScrollviewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _mashupView.alpha = 1.0;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        _mashupView.alpha = MashupAlpha;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _mashupView.alpha = MashupAlpha;
}

@end
