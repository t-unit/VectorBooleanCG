//
//  MWViewController.h
//  VectorBooleanMobile
//
//  Created by Martin Winter on 02.08.12.
//  Copyright (c) 2012 Fortunate Bear, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CanvasController.h"
#import "MWShapesTableViewController.h" // Import here because of protocol.
#import "MWOperationsTableViewController.h"
#import "MWOptionsTableViewController.h"

// This view controller is the rough equivalent of MyDocument on OS X.
@interface MWViewController : UIViewController <MWShapesTableViewControllerDelegate, MWOperationsTableViewControllerDelegate, MWOptionsTableViewControllerDelegate>

- (void)selectShapesForTag:(FBShapesTag)tag;
- (void)performOperationForTag:(FBOperationTag)tag;
- (void)toggleOptionForTag:(FBOptionTag)tag;

@end
