//
//  Geometry.h
//  VectorBrush
//
//  Created by Andrew Finnell on 5/28/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//


// Note: NSPoint has been replaced by CGPoint.


CGFloat FBDistanceBetweenPoints(CGPoint point1, CGPoint point2);
CGFloat FBDistancePointToLine(CGPoint point, CGPoint lineStartPoint, CGPoint lineEndPoint);
CGPoint FBLineNormal(CGPoint lineStart, CGPoint lineEnd);
CGPoint FBLineMidpoint(CGPoint lineStart, CGPoint lineEnd);

CGPoint FBAddPoint(CGPoint point1, CGPoint point2);
CGPoint FBScalePoint(CGPoint point, CGFloat scale);
CGPoint FBUnitScalePoint(CGPoint point, CGFloat scale);
CGPoint FBSubtractPoint(CGPoint point1, CGPoint point2);
CGFloat FBDotMultiplyPoint(CGPoint point1, CGPoint point2);
CGFloat FBPointLength(CGPoint point);
CGFloat FBPointSquaredLength(CGPoint point);
CGPoint FBNormalizePoint(CGPoint point);
CGPoint FBNegatePoint(CGPoint point);
CGPoint FBRoundPoint(CGPoint point);

BOOL FBArePointsClose(CGPoint point1, CGPoint point2);
BOOL FBArePointsCloseWithOptions(CGPoint point1, CGPoint point2, CGFloat threshold);
BOOL FBAreValuesClose(CGFloat value1, CGFloat value2);
BOOL FBAreValuesCloseWithOptions(CGFloat value1, CGFloat value2, CGFloat threshold);
