//
//  PanelOperations+CacheManager.h
//  Idiomics
//
//  Created by Joe Mocquant on 2/9/15.
//  Copyright (c) 2015 Idiomics. All rights reserved.
//

#import "PanelOperations.h"

@interface PanelOperations (CacheManager)

- (NSCachedURLResponse *)getCachedURLResponseForPanel:(Panel *)panel
                                       withDesiredRes:(CGSize)desiredRes;

@end
