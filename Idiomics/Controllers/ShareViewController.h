//
//  ShareViewController.h
//  Idiomics
//
//  Created by Joe Mocquant on 2/14/15.
//  Copyright (c) 2015 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Panel;

@interface ShareViewController : UIActivityViewController
{
    Panel *panel;
    NSDate *trackingIntervalStart;
}

- (instancetype)initWithPanel:(Panel *)p
                   imagePanel:(UIImage *)imagePanel;

@end
