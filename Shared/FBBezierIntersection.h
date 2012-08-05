//
//  FBBezierIntersection.h
//  VectorBoolean
//
//  Created by Andrew Finnell on 6/6/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

#import "MWGeometry.h"
@class FBBezierCurve;

// FBBezierIntersection stores where two bezier curves intersect. Initially it just stores
//  the curves and the parameter values where they intersect. It can lazily compute
//  the 2D point where they intersect, the left and right parts of the curves relative to
//  the intersection point, if the intersection is tangent. 
@interface FBBezierIntersection : NSObject

+ (id) intersectionWithCurve1:(FBBezierCurve *)curve1 parameter1:(MWFloat)parameter1 curve2:(FBBezierCurve *)curve2 parameter2:(MWFloat)parameter2;
- (id) initWithCurve1:(FBBezierCurve *)curve1 parameter1:(MWFloat)parameter1 curve2:(FBBezierCurve *)curve2 parameter2:(MWFloat)parameter2;

@property (readonly) MWPoint location;
@property (readonly, retain) FBBezierCurve *curve1;
@property (readonly) MWFloat parameter1;
@property (readonly, retain) FBBezierCurve *curve2;
@property (readonly) MWFloat parameter2;
@property (readonly, getter = isTangent) BOOL tangent;
@property (readonly) FBBezierCurve *curve1LeftBezier;
@property (readonly) FBBezierCurve *curve1RightBezier;
@property (readonly) FBBezierCurve *curve2LeftBezier;
@property (readonly) FBBezierCurve *curve2RightBezier;

// Intersections at the end points of curves have to be handled carefully, so here
//  are some convience methods to determine if that's the case.
@property (readonly, getter = isAtStartOfCurve1) BOOL atStartOfCurve1;
@property (readonly, getter = isAtStopOfCurve1) BOOL atStopOfCurve1;
@property (readonly, getter = isAtStartOfCurve2) BOOL atStartOfCurve2;
@property (readonly, getter = isAtStopOfCurve2) BOOL atStopOfCurve2;

@property (readonly, getter = isAtEndPointOfCurve1) BOOL atEndPointOfCurve1;
@property (readonly, getter = isAtEndPointOfCurve2) BOOL atEndPointOfCurve2;
@property (readonly, getter = isAtEndPointOfCurve) BOOL atEndPointOfCurve;

@end
