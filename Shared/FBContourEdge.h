//
//  FBContourEdge.h
//  VectorBoolean
//
//  Created by Andrew Finnell on 6/15/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FBBezierCurve;
@class FBBezierContour;
@class FBEdgeCrossing;

// FBContourEdge wraps a bezier curve, and additionally, stores all the places
//  on the curve where crossings happen.
@interface FBContourEdge : NSObject

- (id) initWithBezierCurve:(FBBezierCurve *)curve contour:(FBBezierContour *)contour;

@property (readonly) FBBezierCurve *curve;
@property (readonly) NSMutableArray *crossings; // sorted by parameter of the intersection
@property (readonly, weak) FBBezierContour *contour;
@property NSUInteger index;

// An easy way to iterate all the edges. Wraps around.
@property (readonly) FBContourEdge *next;
@property (readonly) FBContourEdge *previous;

@property (readonly) FBEdgeCrossing *firstCrossing;
@property (readonly) FBEdgeCrossing *lastCrossing;
@property (readonly) NSArray *intersectingEdges;

// Store if there are any intersections at either end of this edge.
@property (getter = isStartShared) BOOL startShared;
@property (getter = isStopShared) BOOL stopShared;

- (void) addCrossing:(FBEdgeCrossing *)crossing;
- (void) removeCrossing:(FBEdgeCrossing *)crossing;
- (void) removeAllCrossings;
- (void) round;

@end
