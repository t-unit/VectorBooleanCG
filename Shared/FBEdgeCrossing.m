//
//  FBEdgeCrossing.m
//  VectorBoolean
//
//  Created by Andrew Finnell on 6/15/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

#import "FBEdgeCrossing.h"
#import "FBContourEdge.h"
#import "FBBezierCurve.h"
#import "FBBezierIntersection.h"

@implementation FBEdgeCrossing

+ (id) crossingWithIntersection:(FBBezierIntersection *)intersection
{
    return [[FBEdgeCrossing alloc] initWithIntersection:intersection];
}

- (id) initWithIntersection:(FBBezierIntersection *)intersection
{
    self = [super init];
    
    if ( self != nil ) {
        _intersection = intersection;
    }
    
    return self;
}

- (void) removeFromEdge
{
    [_edge removeCrossing:self];
}

- (MWFloat) order
{
    return self.parameter;
}

- (FBEdgeCrossing *) next
{
    if ( _index >= ([self.edge.crossings count] - 1) )
        return nil;
    
    return [self.edge.crossings objectAtIndex:_index + 1];
}

- (FBEdgeCrossing *) previous
{
    if ( _index == 0 )
        return nil;
    
    return [self.edge.crossings objectAtIndex:_index - 1];
}

- (MWFloat) parameter
{
    if ( self.edge.curve == _intersection.curve1 )
        return _intersection.parameter1;
    
    return _intersection.parameter2;
}

- (MWPoint) location
{
    return _intersection.location;
}

- (FBBezierCurve *) curve
{
    return self.edge.curve;
}

- (FBBezierCurve *) leftCurve
{
    if ( self.isAtStart )
        return nil;
    
    if ( self.edge.curve == _intersection.curve1 )
        return _intersection.curve1LeftBezier;
    
    return _intersection.curve2LeftBezier;
}

- (FBBezierCurve *) rightCurve
{
    if ( self.isAtEnd )
        return nil;
    
    if ( self.edge.curve == _intersection.curve1 )
        return _intersection.curve1RightBezier;
    
    return _intersection.curve2RightBezier;
}

- (BOOL) isAtStart
{
    if ( self.edge.curve == _intersection.curve1 )
        return _intersection.isAtStartOfCurve1;
    
    return _intersection.isAtStartOfCurve2;
}

- (BOOL) isAtEnd
{
    if ( self.edge.curve == _intersection.curve1 )
        return _intersection.isAtStopOfCurve1;
    
    return _intersection.isAtStopOfCurve2;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"<%@: isEntry = %d, isProcessed = %d, intersection = %@>", 
            NSStringFromClass([self class]),
            (int)_entry,
            (int)_processed,
            [_intersection description]
            ];
}

@end
