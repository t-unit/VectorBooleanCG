//
//  MyDocument.m
//  VectorBoolean
//
//  Created by Andrew Finnell on 5/31/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

#import "MyDocument.h"
#import "CanvasView.h"
#import "CanvasController.h"


@implementation MyDocument
{
    IBOutlet CanvasView *_canvasView;
    CanvasController *_canvasController;
    FBShapesTag _resetTag;
}

- (id)init
{
    self = [super init];
    if (self) {
        _resetTag = FBShapesTagSomeOverlap;
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    _canvasController = [[CanvasController alloc] init];
    _canvasController.canvas = _canvasView.canvas;

    [self onReset:nil];
}


#pragma mark -


- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    /*
     Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
     You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
     */
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    /*
     Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
     You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
     */
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return YES;
}


#pragma mark -


- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem
{
    NSMenuItem *menuItem = (NSMenuItem *)anItem;
    
    if ( [anItem action] == @selector(onSelectShapes:) ) {
        [menuItem setState:(_resetTag == [anItem tag]) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onShowPoints:) ) {
        [menuItem setState:_canvasController.showsPoints ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onShowIntersections:) ) {
        [menuItem setState:_canvasController.showsIntersections ? NSOnState : NSOffState];
    }
    
    return YES;
}


#pragma mark -


- (IBAction) onReset:(id)sender
{
    [_canvasController resetWithTag:_resetTag];
    [_canvasView setNeedsDisplay:YES];
}

- (IBAction) onUnion:(id)sender
{
    [self onReset:sender];
    [_canvasController makeUnion];
}

- (IBAction) onIntersect:(id)sender
{
    [self onReset:sender];
    [_canvasController makeIntersect];
}

- (IBAction) onDifference:(id)sender // Punch
{
    [self onReset:sender];
    [_canvasController makeDifference];
}

- (IBAction) onJoin:(id)sender // XOR
{
    [self onReset:sender];
    [_canvasController makeJoin];
}


#pragma mark -


- (IBAction) onSelectShapes:(id)sender
{
    _resetTag = (FBShapesTag)[sender tag];
    [self onReset:sender];
}

- (IBAction) onShowPoints:(id)sender
{
    [_canvasController togglePoints];
    [_canvasView setNeedsDisplay:YES];
}

- (IBAction) onShowIntersections:(id)sender
{
    [_canvasController toggleIntersections];
    [_canvasView setNeedsDisplay:YES];
}


@end
