//
//  TrackingViewController.h
//  Idiomics
//
//  Created by Joe Mocquant on 12/10/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <GAITrackedViewController.h>
#import <UIKit/UIKit.h>

@interface TrackingViewController : GAITrackedViewController
{
    NSString *panelId; //only for PanelViewController
    NSDate *trackingIntervalStart;
}

@end
