//
//  NavigationView.h
//  Idiomics
//
//  Created by Joe Mocquant on 12/2/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationView : UIView

@property (nonatomic, strong) UIButton *cancel;
@property (nonatomic, strong) UIButton *send;
@property (nonatomic, assign) BOOL isEdited;

- (void)toggleVisibility;
- (void)updateVisibility;

@end
