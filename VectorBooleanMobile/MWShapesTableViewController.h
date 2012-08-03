//
//  MWShapesTableViewController.h
//  VectorBoolean
//
//  Created by Martin Winter on 03.08.12.
//  Copyright (c) 2012 Fortunate Bear, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CanvasController.h"


@protocol MWShapesTableViewControllerDelegate <NSObject>

- (void)selectShapesForTag:(FBShapesTag)tag;

@end


@interface MWShapesTableViewController : UITableViewController

@property (strong) NSArray *shapeTitles;
@property (assign) FBShapesTag selectedTag;
@property (weak) id <MWShapesTableViewControllerDelegate> delegate;

@end
