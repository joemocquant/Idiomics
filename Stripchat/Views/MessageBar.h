//
//  MessageBar.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/10/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessageBarDelegate <NSObject>

@optional

- (void)messageDidChange:(NSString *)text;
- (void)didPressNext;

@end

@interface MessageBar : UIView <UITextViewDelegate>

@property (nonatomic, weak) id<MessageBarDelegate> delegate;

@end
