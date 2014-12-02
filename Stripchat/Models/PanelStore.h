//
//  PanelStore.h
//  Stripchat
//
//  Created by Joe Mocquant on 11/7/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

@class Panel;

@interface PanelStore : NSObject
{
    NSMutableArray *allPanels;
}

+ (instancetype)sharedStore;
- (NSMutableArray *)allPanels;
- (void)addPanel:(Panel *)panel;
- (Panel *)panelAtIndex:(NSUInteger)index;

@end
