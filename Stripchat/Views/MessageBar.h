//
//  MessageBar.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/10/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessageBarDelegate;

@interface MessageBar : UIView <UITextViewDelegate>

@property (nonatomic, weak) id<MessageBarDelegate> delegate;

@end

@protocol MessageBarDelegate <NSObject>

- (void)messageDidChange:(NSString *)text;
- (void)didPressNext;

@end