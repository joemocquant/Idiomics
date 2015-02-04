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
        [self setupMashupScrollView];
        [self setupSeparators];
    }

    return self;
}

- (void)setupMashupScrollView
{
    UIScrollView *mashupScrollView = [[UIScrollView alloc] init];
    [mashupScrollView setDelegate:self];
    [mashupScrollView setShowsHorizontalScrollIndicator:NO];
    
    [self.contentView addSubview:mashupScrollView];
    [mashupScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [mashupScrollView pinEdges:JRTViewPinAllEdges toSameEdgesOfView:self.contentView];
    
    [mashupScrollView setUserInteractionEnabled:NO];
    [self.contentView addGestureRecognizer:mashupScrollView.panGestureRecognizer];
    
    _mashupView = [UIImageView new];
    [_mashupView setContentMode:UIViewContentModeScaleAspectFill];
    
    [mashupScrollView addSubview:_mashupView];
    [_mashupView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_mashupView pinEdges:JRTViewPinAllEdges toSameEdgesOfView:mashupScrollView];
    
    [_mashupView setAlpha:MashupAlpha];
}

- (void)updateMashupConstraints
{
    if (mashupHeightConstraint) {
        [_mashupView removeConstraints:@[mashupHeightConstraint, mashupWidthConstraint]];
    }
    
    //image size is in pixels! converting to points
    mashupHeightConstraint = [_mashupView constrainToHeight:[_mashupView image].size.height / [[UIScreen mainScreen] scale]];
    mashupWidthConstraint = [_mashupView constrainToWidth:[_mashupView image].size.width / [[UIScreen mainScreen] scale]];
}

- (void)setupSeparators
{
    UIView *separatorTop = [UIView new];
    [separatorTop setBackgroundColor:[Colors black]];
    
    [self.contentView addSubview:separatorTop];
    [separatorTop setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [separatorTop pinEdges:JRTViewPinLeftEdge | JRTViewPinTopEdge | JRTViewPinRightEdge
         toSameEdgesOfView:self.contentView];
    [separatorTop constrainToHeight:SeparatorHeight];
    
    UIView *separatorBottom = [UIView new];
    [separatorBottom setBackgroundColor:[Colors black]];
    
    [self.contentView addSubview:separatorBottom];
    [separatorBottom setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [separatorBottom pinEdges:JRTViewPinLeftEdge | JRTViewPinBottomEdge | JRTViewPinRightEdge
            toSameEdgesOfView:self.contentView];
    [separatorBottom constrainToHeight:SeparatorHeight];
}


#pragma mark - UIScrollviewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_mashupView setAlpha:1.0];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [_mashupView setAlpha:MashupAlpha];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_mashupView setAlpha:MashupAlpha];
}

@end
