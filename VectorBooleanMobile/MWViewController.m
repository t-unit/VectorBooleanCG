//
//  MWViewController.m
//  VectorBooleanMobile
//
//  Created by Martin Winter on 02.08.12.
//  Copyright (c) 2012 Martin Winter. All rights reserved.
//

#import "MWViewController.h"
#import "CanvasView.h"
#import "CanvasController.h"


@implementation MWViewController
{
    IBOutlet CanvasView *_canvasView;
    CanvasController *_canvasController;
    FBShapesTag _resetTag;
    
    UIPopoverController *_currentPopoverController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _resetTag = FBShapesTagSomeOverlap;

    _canvasController = [[CanvasController alloc] init];
    _canvasController.canvas = _canvasView.canvas;
    
    [self performOperationForTag:FBOperationTagReset];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark -


- (void)selectShapesForTag:(FBShapesTag)tag
{
    [_currentPopoverController dismissPopoverAnimated:YES];

    _resetTag = tag;
    [self performOperationForTag:FBOperationTagReset];
}


- (void)performOperationForTag:(FBOperationTag)tag
{
    [_currentPopoverController dismissPopoverAnimated:YES];
    
    switch (tag)
    {
        case FBOperationTagReset:
        {
            [_canvasController resetWithTag:_resetTag];
            [_canvasView setNeedsDisplay];
            break;
        }
            
        case FBOperationTagUnion:
        {
            [self performOperationForTag:FBOperationTagReset];
            [_canvasController makeUnion];
            break;
        }
            
        case FBOperationTagIntersect:
        {
            [self performOperationForTag:FBOperationTagReset];
            [_canvasController makeIntersect];
            break;
        }
            
        case FBOperationTagDifference:
        {
            [self performOperationForTag:FBOperationTagReset];
            [_canvasController makeDifference];
            break;
        }
            
        case FBOperationTagJoin:
        {
            [self performOperationForTag:FBOperationTagReset];
            [_canvasController makeJoin];
            break;
        }
            
        default:
            break;
    }
}


- (void)toggleOptionForTag:(FBOptionTag)tag
{
    [_currentPopoverController dismissPopoverAnimated:YES];
    
    switch (tag)
    {
        case FBOptionTagToggleControlPoints:
        {
            [_canvasController togglePoints];
            [_canvasView setNeedsDisplay];
            break;
        }
    
        case FBOptionTagToggleIntersections:
        {
            [_canvasController toggleIntersections];
            [_canvasView setNeedsDisplay];
            break;
        }
    
        default:
            break;
    }
}


#pragma mark -


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Prevent multiple popovers visible at one time.
    if (_currentPopoverController && _currentPopoverController.popoverVisible)
    {
        [_currentPopoverController dismissPopoverAnimated:YES];
    }
    
    if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]])
    {
        _currentPopoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
    }

    
    if ([segue.identifier isEqualToString:@"ShapesSegue"])
    {
        MWShapesTableViewController *shapesTableViewController = (MWShapesTableViewController *)segue.destinationViewController;
        shapesTableViewController.shapeTitles = [CanvasController shapeTitles];
        shapesTableViewController.selectedTag = _resetTag;
        shapesTableViewController.delegate = self;
    }

    else if ([segue.identifier isEqualToString:@"OperationsSegue"])
    {
        MWOperationsTableViewController *operationsTableViewController = (MWOperationsTableViewController *)segue.destinationViewController;
        operationsTableViewController.delegate = self;
    }

    else if ([segue.identifier isEqualToString:@"OptionsSegue"])
    {
        MWOptionsTableViewController *optionsTableViewController = (MWOptionsTableViewController *)segue.destinationViewController;
        optionsTableViewController.showsPoints = _canvasController.showsPoints;
        optionsTableViewController.showsIntersections = _canvasController.showsIntersections;
        optionsTableViewController.delegate = self;
    }
}


@end
