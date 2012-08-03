//
//  Geometry.m
//  VectorBrush
//
//  Created by Andrew Finnell on 5/28/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

#import "Geometry.h"

static const CGFloat FBPointClosenessThreshold = 1e-10;


CGFloat FBDistanceBetweenPoints(CGPoint point1, CGPoint point2)
{
    CGFloat xDelta = point2.x - point1.x;
    CGFloat yDelta = point2.y - point1.y;
    return sqrtf(xDelta * xDelta + yDelta * yDelta);
}

CGFloat FBDistancePointToLine(CGPoint point, CGPoint lineStartPoint, CGPoint lineEndPoint)
{
    CGFloat lineLength = FBDistanceBetweenPoints(lineStartPoint, lineEndPoint);
    if ( lineLength == 0 )
        return 0;
    CGFloat u = ((point.x - lineStartPoint.x) * (lineEndPoint.x - lineStartPoint.x) + (point.y - lineStartPoint.y) * (lineEndPoint.y - lineStartPoint.y)) / (lineLength * lineLength);
    CGPoint intersectionPoint = CGPointMake(lineStartPoint.x + u * (lineEndPoint.x - lineStartPoint.x), lineStartPoint.y + u * (lineEndPoint.y - lineStartPoint.y));
    return FBDistanceBetweenPoints(point, intersectionPoint);
}

CGPoint FBAddPoint(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

CGPoint FBUnitScalePoint(CGPoint point, CGFloat scale)
{
    CGPoint result = point;
    CGFloat length = FBPointLength(point);
    if ( length != 0.0 ) {
        result.x *= scale/length;
        result.y *= scale/length;
    }
    return result;
}

CGPoint FBScalePoint(CGPoint point, CGFloat scale)
{
    return CGPointMake(point.x * scale, point.y * scale);
}

CGFloat FBDotMultiplyPoint(CGPoint point1, CGPoint point2)
{
    return point1.x * point2.x + point1.y * point2.y;
}

CGPoint FBSubtractPoint(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x - point2.x, point1.y - point2.y);
}

CGFloat FBPointLength(CGPoint point)
{
    return sqrtf((point.x * point.x) + (point.y * point.y));
}

CGFloat FBPointSquaredLength(CGPoint point)
{
    return (point.x * point.x) + (point.y * point.y);
}

CGPoint FBNormalizePoint(CGPoint point)
{
    CGPoint result = point;
    CGFloat length = FBPointLength(point);
    if ( length != 0.0 ) {
        result.x /= length;
        result.y /= length;
    }
    return result;
}

CGPoint FBNegatePoint(CGPoint point)
{
    return CGPointMake(-point.x, -point.y);
}

CGPoint FBRoundPoint(CGPoint point)
{
    CGPoint result = { roundf(point.x), roundf(point.y) };
    return result;
}

CGPoint FBLineNormal(CGPoint lineStart, CGPoint lineEnd)
{
    return FBNormalizePoint(CGPointMake(-(lineEnd.y - lineStart.y), lineEnd.x - lineStart.x));
}

CGPoint FBLineMidpoint(CGPoint lineStart, CGPoint lineEnd)
{
    CGFloat distance = FBDistanceBetweenPoints(lineStart, lineEnd);
    CGPoint tangent = FBNormalizePoint(FBSubtractPoint(lineEnd, lineStart));
    return FBAddPoint(lineStart, FBUnitScalePoint(tangent, distance / 2.0));
}

BOOL FBArePointsClose(CGPoint point1, CGPoint point2)
{
    return FBArePointsCloseWithOptions(point1, point2, FBPointClosenessThreshold);
}

BOOL FBArePointsCloseWithOptions(CGPoint point1, CGPoint point2, CGFloat threshold)
{
    return FBAreValuesCloseWithOptions(point1.x, point2.x, threshold) && FBAreValuesCloseWithOptions(point1.y, point2.y, threshold);
}

BOOL FBAreValuesClose(CGFloat value1, CGFloat value2)
{
    return FBAreValuesCloseWithOptions(value1, value2, FBPointClosenessThreshold);
}

BOOL FBAreValuesCloseWithOptions(CGFloat value1, CGFloat value2, CGFloat threshold)
{
    CGFloat delta = value1 - value2;    
    return (delta <= threshold) && (delta >= -threshold);
}
