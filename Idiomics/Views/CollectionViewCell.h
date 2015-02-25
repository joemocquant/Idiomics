//
//  CollectionViewCell.h
//  Idiomics
//
//  Created by Joe Mocquant on 12/15/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UITableViewCell <UIScrollViewDelegate>
{
    NSLayoutConstraint *mashupWidthConstraint;
    NSLayoutConstraint *mashupHeightConstraint;
}

@property (nonatomic, readonly, strong) UIImageView *mashupView;
@property (nonatomic, readwrite, strong) UIImageView *iconView;

@end
