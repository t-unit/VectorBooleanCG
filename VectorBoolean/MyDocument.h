//
//  MyDocument.h
//  VectorBoolean
//
//  Created by Andrew Finnell on 5/31/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MyDocument : NSDocument

- (IBAction) onReset:(id)sender;
- (IBAction) onUnion:(id)sender;
- (IBAction) onIntersect:(id)sender;
- (IBAction) onDifference:(id)sender; // Punch
- (IBAction) onJoin:(id)sender; // XOR

- (IBAction) onSelectShapes:(id)sender;
- (IBAction) onShowPoints:(id)sender;
- (IBAction) onShowIntersections:(id)sender;

@end
