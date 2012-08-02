//
//  FBBezierCurve.h
//  VectorBoolean
//
//  Created by Andrew Finnell on 6/6/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

// FBRange is a range of parameter (t)
typedef struct FBRange {
    CGFloat minimum;
    CGFloat maximum;
} FBRange;

extern FBRange FBRangeMake(CGFloat minimum, CGFloat maximum);
extern BOOL FBRangeHasConverged(FBRange range, NSUInteger places);
extern CGFloat FBRangeGetSize(FBRange range);
extern CGFloat FBRangeAverage(FBRange range);
extern CGFloat FBRangeScaleNormalizedValue(FBRange range, CGFloat value);

// FBBezierCurve is one cubic 2D bezier curve. It represents one segment of a bezier path, and is where
//  the intersection calculation happens
@interface FBBezierCurve : NSObject {
    CGPoint _endPoint1;
    CGPoint _controlPoint1;
    CGPoint _controlPoint2;
    CGPoint _endPoint2;
}

+ (NSArray *) bezierCurvesFromBezierPath:(CGPathRef)path;

+ (id) bezierCurveWithLineStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
+ (id) bezierCurveWithEndPoint1:(CGPoint)endPoint1 controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2 endPoint2:(CGPoint)endPoint2;

- (id) initWithEndPoint1:(CGPoint)endPoint1 controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2 endPoint2:(CGPoint)endPoint2;
- (id) initWithLineStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

@property CGPoint endPoint1;
@property CGPoint controlPoint1;
@property CGPoint controlPoint2;
@property CGPoint endPoint2;

- (NSArray *) intersectionsWithBezierCurve:(FBBezierCurve *)curve;

- (CGPoint) pointAtParameter:(CGFloat)parameter leftBezierCurve:(FBBezierCurve **)leftBezierCurve rightBezierCurve:(FBBezierCurve **)rightBezierCurve;
- (FBBezierCurve *) subcurveWithRange:(FBRange)range;

- (void) round;

@end
