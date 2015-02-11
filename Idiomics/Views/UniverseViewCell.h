//
//  UniverseViewCell.h
//  Idiomics
//
//  Created by Joe Mocquant on 12/15/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UniverseViewCell : UITableViewCell <UIScrollViewDelegate>
{
    NSLayoutConstraint *mashupWidthConstraint;
    NSLayoutConstraint *mashupHeightConstraint;
}

@property (nonatomic, readonly, strong) UIImageView *mashupView;

@end
