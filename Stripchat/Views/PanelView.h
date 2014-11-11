//
//  PanelView.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/10/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Panel.h"

@interface PanelView : UIView <UIScrollViewDelegate>
{
    UIScrollView *panelScrollView;
    UIImageView *cellImageView;
}

@property (nonatomic, strong) Panel *panel;
@property (nonatomic, strong) UIImageView *panelImageView;

- (instancetype)initWithPanel:(Panel *)p fromCellImageView:(UIImageView *)civ;
- (UIScrollView *)panelScrollView;

@end
