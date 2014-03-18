//
//  MWOptionsTableViewController.m
//  VectorBoolean
//
//  Created by Martin Winter on 03.08.12.
//  Copyright (c) 2012 Fortunate Bear, LLC. All rights reserved.
//

#import "MWOptionsTableViewController.h"

@implementation MWOptionsTableViewController
{
    IBOutlet UITableViewCell *_controlPointsCell;
    IBOutlet UITableViewCell *_intersectionsCell;
}

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
    
    _controlPointsCell.accessoryType = (self.showsPoints) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    _intersectionsCell.accessoryType = (self.showsIntersections) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toggleOptionForTag:)])
    {
        [self.delegate toggleOptionForTag:(FBOptionTag)indexPath.row];
    }
}

@end
