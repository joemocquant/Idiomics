//
//  LibraryViewController.h
//  Idiomics
//
//  Created by Joe Mocquant on 12/15/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackingViewController.h"
#import "LibraryOperations.h"

@interface LibraryViewController : TrackingViewController <UITableViewDelegate,
                                                           UITableViewDataSource,
                                                           LibraryOperationsDelegate>
{
    LibraryOperations *libraryOperations;
    
    UITableView *tv;
}

@end
