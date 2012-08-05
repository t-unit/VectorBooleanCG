//
//  FBGeometry.m
//  VectorBrush
//
//  Created by Andrew Finnell on 5/28/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

#import "FBGeometry.h"

static const MWFloat FBPointClosenessThreshold = 1e-10;


MWFloat FBDistanceBetweenPoints(MWPoint point1, MWPoint point2)
{
    MWFloat xDelta = point2.x - point1.x;
    MWFloat yDelta = point2.y - point1.y;
    return sqrt(xDelta * xDelta + yDelta * yDelta);
}

MWFloat FBDistancePointToLine(MWPoint point, MWPoint lineStartPoint, MWPoint lineEndPoint)
{
    MWFloat lineLength = FBDistanceBetweenPoints(lineStartPoint, lineEndPoint);
    if ( lineLength == 0 )
        return 0;
    MWFloat u = ((point.x - lineStartPoint.x) * (lineEndPoint.x - lineStartPoint.x) + (point.y - lineStartPoint.y) * (lineEndPoint.y - lineStartPoint.y)) / (lineLength * lineLength);
    MWPoint intersectionPoint = MWPointMake(lineStartPoint.x + u * (lineEndPoint.x - lineStartPoint.x), lineStartPoint.y + u * (lineEndPoint.y - lineStartPoint.y));
    return FBDistanceBetweenPoints(point, intersectionPoint);
}

MWPoint FBAddPoint(MWPoint point1, MWPoint point2)
{
    return MWPointMake(point1.x + point2.x, point1.y + point2.y);
}

MWPoint FBUnitScalePoint(MWPoint point, MWFloat scale)
{
    MWPoint result = point;
    MWFloat length = FBPointLength(point);
    if ( length != 0.0 ) {
        result.x *= scale/length;
        result.y *= scale/length;
    }
    return result;
}

MWPoint FBScalePoint(MWPoint point, MWFloat scale)
{
    return MWPointMake(point.x * scale, point.y * scale);
}

MWFloat FBDotMultiplyPoint(MWPoint point1, MWPoint point2)
{
    return point1.x * point2.x + point1.y * point2.y;
}

MWPoint FBSubtractPoint(MWPoint point1, MWPoint point2)
{
    return MWPointMake(point1.x - point2.x, point1.y - point2.y);
}

MWFloat FBPointLength(MWPoint point)
{
    return sqrt((point.x * point.x) + (point.y * point.y));
}

MWFloat FBPointSquaredLength(MWPoint point)
{
    return (point.x * point.x) + (point.y * point.y);
}

MWPoint FBNormalizePoint(MWPoint point)
{
    MWPoint result = point;
    MWFloat length = FBPointLength(point);
    if ( length != 0.0 ) {
        result.x /= length;
        result.y /= length;
    }
    return result;
}

MWPoint FBNegatePoint(MWPoint point)
{
    return MWPointMake(-point.x, -point.y);
}

MWPoint FBRoundPoint(MWPoint point)
{
    MWPoint result = { round(point.x), round(point.y) };
    return result;
}

MWPoint FBLineNormal(MWPoint lineStart, MWPoint lineEnd)
{
    return FBNormalizePoint(MWPointMake(-(lineEnd.y - lineStart.y), lineEnd.x - lineStart.x));
}

MWPoint FBLineMidpoint(MWPoint lineStart, MWPoint lineEnd)
{
    MWFloat distance = FBDistanceBetweenPoints(lineStart, lineEnd);
    MWPoint tangent = FBNormalizePoint(FBSubtractPoint(lineEnd, lineStart));
    return FBAddPoint(lineStart, FBUnitScalePoint(tangent, distance / 2.0));
}

BOOL FBArePointsClose(MWPoint point1, MWPoint point2)
{
    return FBArePointsCloseWithOptions(point1, point2, FBPointClosenessThreshold);
}

BOOL FBArePointsCloseWithOptions(MWPoint point1, MWPoint point2, MWFloat threshold)
{
    return FBAreValuesCloseWithOptions(point1.x, point2.x, threshold) && FBAreValuesCloseWithOptions(point1.y, point2.y, threshold);
}

BOOL FBAreValuesClose(MWFloat value1, MWFloat value2)
{
    return FBAreValuesCloseWithOptions(value1, value2, FBPointClosenessThreshold);
}

BOOL FBAreValuesCloseWithOptions(MWFloat value1, MWFloat value2, MWFloat threshold)
{
    MWFloat delta = value1 - value2;    
    return (delta <= threshold) && (delta >= -threshold);
}
