//
//  FBBezierContour.h
//  VectorBoolean
//
//  Created by Andrew Finnell on 6/15/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

#import "MWGeometry.h"

@class FBBezierCurve;
@class FBEdgeCrossing;

typedef enum FBContourInside {
    FBContourInsideFilled,
    FBContourInsideHole
} FBContourInside;

// FBBezierContour represents a closed path of bezier curves (aka edges). Contours
//  can be filled or represent a hole in another contour.
@interface FBBezierContour : NSObject<NSCopying> {
    NSMutableArray *_edges;
    MWRect _bounds;
    FBContourInside _inside;
}

// Methods for building up the contour. The reverse forms flip points in the bezier curve before adding them
//  to the contour. The crossing to crossing methods assuming the crossings are on the same edge. One of
//  crossings can be nil, but not both.
- (void) addCurve:(FBBezierCurve *)curve;
- (void) addCurveFrom:(FBEdgeCrossing *)startCrossing to:(FBEdgeCrossing *)endCrossing;
- (void) addReverseCurve:(FBBezierCurve *)curve;
- (void) addReverseCurveFrom:(FBEdgeCrossing *)startCrossing to:(FBEdgeCrossing *)endCrossing;

- (BOOL) containsPoint:(MWPoint)point;
- (void) markCrossingsAsEntryOrExitWithContour:(FBBezierContour *)otherContour markInside:(BOOL)markInside;

- (void) round;

@property (readonly) NSArray *edges;
@property (readonly) MWRect bounds;
@property (readonly) MWPoint firstPoint;
@property FBContourInside inside;
@property (readonly) NSArray *intersectingContours;

@end
