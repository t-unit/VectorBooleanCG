//
//  FBBezierIntersection.m
//  VectorBoolean
//
//  Created by Andrew Finnell on 6/6/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

#import "FBBezierIntersection.h"
#import "FBBezierCurve.h"
#import "FBGeometry.h"

@interface FBBezierIntersection ()
{
    BOOL _tangent;
    BOOL _needToComputeCurve1;
    BOOL _needToComputeCurve2;
}

- (void) computeCurve1;
- (void) computeCurve2;

@end

@implementation FBBezierIntersection

@synthesize location = _location;
@synthesize curve1LeftBezier = _curve1LeftBezier;
@synthesize curve1RightBezier = _curve1RightBezier;
@synthesize curve2LeftBezier = _curve2LeftBezier;
@synthesize curve2RightBezier = _curve2RightBezier;

+ (id) intersectionWithCurve1:(FBBezierCurve *)curve1 parameter1:(MWFloat)parameter1 curve2:(FBBezierCurve *)curve2 parameter2:(MWFloat)parameter2
{
    return [[FBBezierIntersection alloc] initWithCurve1:curve1 parameter1:parameter1 curve2:curve2 parameter2:parameter2];
}

- (id) initWithCurve1:(FBBezierCurve *)curve1 parameter1:(MWFloat)parameter1 curve2:(FBBezierCurve *)curve2 parameter2:(MWFloat)parameter2
{
    self = [super init];
    
    if ( self != nil ) {
        _curve1 = curve1;
        _parameter1 = parameter1;
        _curve2 = curve2;
        _parameter2 = parameter2;
        _needToComputeCurve1 = YES;
        _needToComputeCurve2 = YES;
    }
    
    return self;
}

- (MWPoint) location
{
    [self computeCurve1];
    return _location;
}

- (BOOL) isTangent
{
    // If we're at the end of a curve, it's not tangent, so skip all the calculations
    if ( self.isAtEndPointOfCurve )
        return NO;
    
    [self computeCurve1];
    [self computeCurve2];

    static const MWFloat FBPointCloseThreshold = 1e-7;
    
    // Compute the tangents at the intersection. 
    MWPoint curve1LeftTangent = FBNormalizePoint(FBSubtractPoint(_curve1LeftBezier.controlPoint2, _curve1LeftBezier.endPoint2));
    MWPoint curve1RightTangent = FBNormalizePoint(FBSubtractPoint(_curve1RightBezier.controlPoint1, _curve1RightBezier.endPoint1));
    MWPoint curve2LeftTangent = FBNormalizePoint(FBSubtractPoint(_curve2LeftBezier.controlPoint2, _curve2LeftBezier.endPoint2));
    MWPoint curve2RightTangent = FBNormalizePoint(FBSubtractPoint(_curve2RightBezier.controlPoint1, _curve2RightBezier.endPoint1));
        
    // See if the tangents are the same. If so, then we're tangent at the intersection point
    return FBArePointsCloseWithOptions(curve1LeftTangent, curve2LeftTangent, FBPointCloseThreshold) || FBArePointsCloseWithOptions(curve1LeftTangent, curve2RightTangent, FBPointCloseThreshold) || FBArePointsCloseWithOptions(curve1RightTangent, curve2LeftTangent, FBPointCloseThreshold) || FBArePointsCloseWithOptions(curve1RightTangent, curve2RightTangent, FBPointCloseThreshold);
}

- (FBBezierCurve *) curve1LeftBezier
{
    [self computeCurve1];
    return _curve1LeftBezier;
}

- (FBBezierCurve *) curve1RightBezier
{
    [self computeCurve1];
    return _curve1RightBezier;
}

- (FBBezierCurve *) curve2LeftBezier
{
    [self computeCurve2];
    return _curve2LeftBezier;
}

- (FBBezierCurve *) curve2RightBezier
{
    [self computeCurve2];
    return _curve2RightBezier;
}

- (BOOL) isAtStartOfCurve1
{
    return FBAreValuesClose(_parameter1, 0.0);
}

- (BOOL) isAtStopOfCurve1
{
    return FBAreValuesClose(_parameter1, 1.0);
}

- (BOOL) isAtEndPointOfCurve1
{
    return self.isAtStartOfCurve1 || self.isAtStopOfCurve1;
}

- (BOOL) isAtStartOfCurve2
{
    return FBAreValuesClose(_parameter2, 0.0);
}

- (BOOL) isAtStopOfCurve2
{
    return FBAreValuesClose(_parameter2, 1.0);
}

- (BOOL) isAtEndPointOfCurve2
{
    return self.isAtStartOfCurve2 || self.isAtStopOfCurve2;
}

- (BOOL) isAtEndPointOfCurve
{
    return self.isAtEndPointOfCurve1 || self.isAtEndPointOfCurve2;
}

- (void) computeCurve1
{
    if ( !_needToComputeCurve1 )
        return;
    
    // Use local variables to make this work with ARC.
    FBBezierCurve *localBezier1;
    FBBezierCurve *localBezier2;
    _location = [_curve1 pointAtParameter:_parameter1 leftBezierCurve:&localBezier1 rightBezierCurve:&localBezier2];
    _curve1LeftBezier = localBezier1;
    _curve1RightBezier = localBezier2;
    
    _needToComputeCurve1 = NO;
}

- (void) computeCurve2
{
    if ( !_needToComputeCurve2 )
        return;
    
    // Use local variables to make this work with ARC.
    FBBezierCurve *localBezier1;
    FBBezierCurve *localBezier2;
    [_curve2 pointAtParameter:_parameter2 leftBezierCurve:&localBezier1 rightBezierCurve:&localBezier2];
    _curve2LeftBezier = localBezier1;
    _curve2RightBezier = localBezier2;
    
    _needToComputeCurve2 = NO;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"<%@: location = (%f, %f), isTangent = %d>", 
            NSStringFromClass([self class]),
            self.location.x, self.location.y,
            (int)self.isTangent];
}

@end
