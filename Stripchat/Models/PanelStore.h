//
//  PanelStore.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/7/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Panel;

@interface PanelStore : NSObject
{
    NSMutableArray *allPanels;
}

+ (instancetype)sharedStore;
- (NSMutableArray *)allPanels;
- (void)addPanel:(Panel *)panel;

@end
