//
//  MWOperationsTableViewController.h
//  VectorBoolean
//
//  Created by Martin Winter on 03.08.12.
//  Copyright (c) 2012 Fortunate Bear, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CanvasController.h"


@protocol MWOperationsTableViewControllerDelegate <NSObject>

- (void)performOperationForTag:(FBOperationTag)tag;

@end


@interface MWOperationsTableViewController : UITableViewController

@property (weak) id <MWOperationsTableViewControllerDelegate> delegate;

@end
