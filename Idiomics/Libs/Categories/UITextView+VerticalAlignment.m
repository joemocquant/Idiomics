//
//  UITextView+VerticalAlignment.m
//  Idiomics
//
//  Created by Joe Mocquant on 2/3/15.
//  Copyright (c) 2015 Idiomics. All rights reserved.
//

#import "UITextView+VerticalAlignment.h"

@implementation UITextView (VerticalAlignment)


- (void)updateTextFontSize
{
    [self centerContentVertically];
    
    CGSize textViewSize = self.frame.size;
    CGFloat maxFontSize = textViewSize.height * 0.6;
    
    UIFont *expectFont = self.font;
    if ([self calculHeight] > textViewSize.height) {
        
        while ([self calculHeight] > textViewSize.height) {
            self.font = [self.font fontWithSize:(self.font.pointSize - 1)];
            expectFont = self.font;
            [self centerContentVertically];
        }
        
    } else {
        
        while ((self.font.pointSize < maxFontSize) && ([self calculHeight] < textViewSize.height)) {
            expectFont = self.font;
            self.font = [self.font fontWithSize:(self.font.pointSize + 1)];
            [self centerContentVertically];
        }
        
        self.font = expectFont;
        [self centerContentVertically];
    }
}

- (void)centerContentVertically
{
    CGFloat topOffset = ([self frame].size.height - [self calculHeight]) / 2;
    if (topOffset < 0.0) {
        topOffset = 0.0;
    }
    
    //topOffset += 10;
    self.textContainerInset = UIEdgeInsetsMake(topOffset, 0.0f, -topOffset, 0.0f);
}

- (CGFloat)calculHeight
{
    return [self sizeThatFits:CGSizeMake(self.frame.size.width, MAXFLOAT)].height;
}

@end
