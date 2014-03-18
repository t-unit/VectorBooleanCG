//
//  CGPath_Boolean.c
//  VectorBoolean
//
//  Created by Martin Winter on 02.08.12.
//  Based on work by Andrew Finnell of Fortunate Bear, LLC.
//  Copyright (c) 2012 Martin Winter. All rights reserved.
//

#include "CGPath_Boolean.h"
#include "FBBezierGraph.h"


CGPathRef CGPath_FBCreateUnion( CGPathRef path, CGPathRef otherPath )
{
    FBBezierGraph *thisGraph = [FBBezierGraph bezierGraphWithBezierPath:path];
    FBBezierGraph *otherGraph = [FBBezierGraph bezierGraphWithBezierPath:otherPath];
    CGPathRef result = [[thisGraph unionWithBezierGraph:otherGraph] newBezierPath];
    // TODO: attributes are property of CGContext, not CGPath; or use UIBezierPath
    return result;
}


CGPathRef CGPath_FBCreateIntersect( CGPathRef path, CGPathRef otherPath )
{
    FBBezierGraph *thisGraph = [FBBezierGraph bezierGraphWithBezierPath:path];
    FBBezierGraph *otherGraph = [FBBezierGraph bezierGraphWithBezierPath:otherPath];
    CGPathRef result = [[thisGraph intersectWithBezierGraph:otherGraph] newBezierPath];
    // TODO: attributes are property of CGContext, not CGPath; or use UIBezierPath
    return result;
}


CGPathRef CGPath_FBCreateDifference( CGPathRef path, CGPathRef otherPath )
{
    FBBezierGraph *thisGraph = [FBBezierGraph bezierGraphWithBezierPath:path];
    FBBezierGraph *otherGraph = [FBBezierGraph bezierGraphWithBezierPath:otherPath];
    CGPathRef result = [[thisGraph differenceWithBezierGraph:otherGraph] newBezierPath];
    // TODO: attributes are property of CGContext, not CGPath; or use UIBezierPath
    return result;
}


CGPathRef CGPath_FBCreateXOR( CGPathRef path, CGPathRef otherPath )
{
    FBBezierGraph *thisGraph = [FBBezierGraph bezierGraphWithBezierPath:path];
    FBBezierGraph *otherGraph = [FBBezierGraph bezierGraphWithBezierPath:otherPath];
    CGPathRef result = [[thisGraph xorWithBezierGraph:otherGraph] newBezierPath];
    // TODO: attributes are property of CGContext, not CGPath; or use UIBezierPath
    return result;
}
