//
//  PanelItemProvider.m
//  Idiomics
//
//  Created by Joe Mocquant on 2/14/15.
//  Copyright (c) 2015 Idiomics. All rights reserved.
//

#import "PanelItemProvider.h"
#import "UIImage+Tools.h"
#import <GAI.h>
#import <GAIDictionaryBuilder.h>

@implementation PanelItemProvider

- (id)item
{
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"share_network_selection"
                                                           label:self.activityType
                                                           value:nil] build]];
    
    if ([self.activityType isEqualToString:UIActivityTypeMessage]) {

        UIImage *result = self.placeholderItem;
        return [result resizeToRatio:4/3.0];
    
    } else if ([self.activityType isEqualToString:@"com.toyopagroup.picaboo.share"]) {

        return [self getSnapchatItem];
        
    } else {
        
        return self.placeholderItem;
    }
}


#pragma mark - Private methods

- (UIImage *)getSnapchatItem
{
    UIImage *panel = self.placeholderItem;
    
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat screenWidth = CGRectGetWidth(screen);
    CGFloat screenHeight = CGRectGetHeight(screen);
    
    CGFloat panelWidth = panel.size.width;
    CGFloat panelHeight = panel.size.height;
    
    CGSize size;
    
    //if (panelWidth <= screenWidth && panelHeight <= screenHeight) {
    //    size = CGSizeMake(panelWidth, panelHeight);
        
    //} else {
        if ((panelWidth / panelHeight) >= (screenWidth / screenHeight)) {
            size = CGSizeMake(screenWidth, screenWidth * panelHeight /panelWidth);
        } else {
            size = CGSizeMake(screenHeight * panelWidth / panelHeight, screenHeight);
        }
    //}
    
    UIGraphicsBeginImageContextWithOptions(screen.size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(ctx, (screenWidth - size.width) / 2, (screenHeight - size.height) / 2);
    
    [panel drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

@end
