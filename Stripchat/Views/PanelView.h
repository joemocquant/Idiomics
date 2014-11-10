//
//  PanelView.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/10/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PanelView : UIView <UIScrollViewDelegate>
{
    UIImageView *panelImageView;
    UIScrollView *panelScrollView;
    UIImageView *cellImageView;
}

- (instancetype)initWithCell:(UIImageView *)civ;
- (UIScrollView *)panelScrollView;

@end
