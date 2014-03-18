//
//  FBBezierCurve.h
//  VectorBoolean
//
//  Created by Andrew Finnell on 6/6/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

#import "MWGeometry.h"

// FBRange is a range of parameter (t)
typedef struct FBRange {
    MWFloat minimum;
    MWFloat maximum;
} FBRange;

extern FBRange FBRangeMake(MWFloat minimum, MWFloat maximum);
extern BOOL FBRangeHasConverged(FBRange range, NSUInteger places);
extern MWFloat FBRangeGetSize(FBRange range);
extern MWFloat FBRangeAverage(FBRange range);
extern MWFloat FBRangeScaleNormalizedValue(FBRange range, MWFloat value);

// FBBezierCurve is one cubic 2D bezier curve. It represents one segment of a bezier path, and is where
//  the intersection calculation happens
@interface FBBezierCurve : NSObject {
    MWPoint _endPoint1;
    MWPoint _controlPoint1;
    MWPoint _controlPoint2;
    MWPoint _endPoint2;
}

+ (NSArray *) bezierCurvesFromBezierPath:(CGPathRef)path;

+ (id) bezierCurveWithLineStartPoint:(MWPoint)startPoint endPoint:(MWPoint)endPoint;
+ (id) bezierCurveWithEndPoint1:(MWPoint)endPoint1 controlPoint1:(MWPoint)controlPoint1 controlPoint2:(MWPoint)controlPoint2 endPoint2:(MWPoint)endPoint2;

- (id) initWithEndPoint1:(MWPoint)endPoint1 controlPoint1:(MWPoint)controlPoint1 controlPoint2:(MWPoint)controlPoint2 endPoint2:(MWPoint)endPoint2;
- (id) initWithLineStartPoint:(MWPoint)startPoint endPoint:(MWPoint)endPoint;

@property MWPoint endPoint1;
@property MWPoint controlPoint1;
@property MWPoint controlPoint2;
@property MWPoint endPoint2;

- (NSArray *) intersectionsWithBezierCurve:(FBBezierCurve *)curve;

- (MWPoint) pointAtParameter:(MWFloat)parameter leftBezierCurve:(FBBezierCurve **)leftBezierCurve rightBezierCurve:(FBBezierCurve **)rightBezierCurve;
- (FBBezierCurve *) subcurveWithRange:(FBRange)range;

- (void) round;

@end
