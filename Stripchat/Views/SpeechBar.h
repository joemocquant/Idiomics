//
//  SpeechBar.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/10/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PanelView.h"

@interface SpeechBar : UIView <UITextViewDelegate>
{
    UITextView *speechTextField;
    PanelView *panelView;
}

- (instancetype)initWithPanelView:(PanelView *)pv;

@end
