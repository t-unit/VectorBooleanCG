//
//  MWOptionsTableViewController.h
//  VectorBoolean
//
//  Created by Martin Winter on 03.08.12.
//  Copyright (c) 2012 Fortunate Bear, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CanvasController.h"


@protocol MWOptionsTableViewControllerDelegate <NSObject>

- (void)toggleOptionForTag:(FBOptionTag)tag;

@end


@interface MWOptionsTableViewController : UITableViewController

@property (assign) BOOL showsPoints;
@property (assign) BOOL showsIntersections;
@property (weak) id <MWOptionsTableViewControllerDelegate> delegate;

@end
