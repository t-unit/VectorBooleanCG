//
//  FBGeometry.h
//  VectorBrush
//
//  Created by Andrew Finnell on 5/28/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//


#include "MWGeometry.h"


MWFloat FBDistanceBetweenPoints(MWPoint point1, MWPoint point2);
MWFloat FBDistancePointToLine(MWPoint point, MWPoint lineStartPoint, MWPoint lineEndPoint);
MWPoint FBLineNormal(MWPoint lineStart, MWPoint lineEnd);
MWPoint FBLineMidpoint(MWPoint lineStart, MWPoint lineEnd);

MWPoint FBAddPoint(MWPoint point1, MWPoint point2);
MWPoint FBScalePoint(MWPoint point, MWFloat scale);
MWPoint FBUnitScalePoint(MWPoint point, MWFloat scale);
MWPoint FBSubtractPoint(MWPoint point1, MWPoint point2);
MWFloat FBDotMultiplyPoint(MWPoint point1, MWPoint point2);
MWFloat FBPointLength(MWPoint point);
MWFloat FBPointSquaredLength(MWPoint point);
MWPoint FBNormalizePoint(MWPoint point);
MWPoint FBNegatePoint(MWPoint point);
MWPoint FBRoundPoint(MWPoint point);

BOOL FBArePointsClose(MWPoint point1, MWPoint point2);
BOOL FBArePointsCloseWithOptions(MWPoint point1, MWPoint point2, MWFloat threshold);
BOOL FBAreValuesClose(MWFloat value1, MWFloat value2);
BOOL FBAreValuesCloseWithOptions(MWFloat value1, MWFloat value2, MWFloat threshold);
