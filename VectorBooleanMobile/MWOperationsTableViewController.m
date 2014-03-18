//
//  MWOperationsTableViewController.m
//  VectorBoolean
//
//  Created by Martin Winter on 03.08.12.
//  Copyright (c) 2012 Fortunate Bear, LLC. All rights reserved.
//

#import "MWOperationsTableViewController.h"
#import "CanvasController.h"


@implementation MWOperationsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger previousRowCount = 0;
    
    for (NSUInteger sectionIndex = 0; sectionIndex < indexPath.section; sectionIndex++)
    {
        previousRowCount += [tableView numberOfRowsInSection:sectionIndex];
    }
    
    FBOperationTag tag = (FBOperationTag)(previousRowCount + indexPath.row);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(performOperationForTag:)])
    {
        [self.delegate performOperationForTag:tag];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
