//
//  CGPath_Utilities.m
//  VectorBoolean
//
//  Created by Martin Winter on 02.08.12.
//  Copyright (c) 2012 Fortunate Bear, LLC. All rights reserved.
//

#include "CGPath_Utilities.h"


void CGPath_FBElementAtIndex_ApplierFunction ( void *info, const CGPathElement *element );
void CGPath_FBElementCount_ApplierFunction ( void *info, const CGPathElement *element );


CGPoint CGPath_FBPointAtIndex ( CGPathRef path, NSUInteger index )
{
    return CGPath_FBElementAtIndex(path, index).point;
}


FBBezierElement CGPath_FBElementAtIndex ( CGPathRef path, NSUInteger index )
{
    FBBezierElement element = {};
    
    // Use CGPathApply in lieu of -[NSBezierPath elementAtIndex:associatedPoints:].
    NSMutableDictionary *dictionary = [@{ @"targetIndex" : @( index ) } mutableCopy];
    CGPathApply(path, (__bridge void *)(dictionary), CGPath_FBElementAtIndex_ApplierFunction);
    
    NSNumber *typeNumber = dictionary[@"type"];
    if (!typeNumber)
    {
        return element;
    }
    
    element.kind = (CGPathElementType)[typeNumber intValue];
    CGPoint *points = (CGPoint *)[(NSData *)dictionary[@"points"] bytes];

    switch (element.kind) {
        case kCGPathElementMoveToPoint:
        case kCGPathElementAddLineToPoint:
        case kCGPathElementCloseSubpath:
            element.point = points[0];
            break;
            
        case kCGPathElementAddCurveToPoint:
            element.controlPoints[0] = points[0];
            element.controlPoints[1] = points[1];
            element.point = points[2];
            break;
        
        case kCGPathElementAddQuadCurveToPoint:
        default:
            NSLog(@"%s  Encountered unhandled element type kCGPathElementAddQuadCurveToPoint", __PRETTY_FUNCTION__);
            break;
    }
    return element;
}


CGPathRef CGPath_FBCreateSubpathWithRange ( CGPathRef path, NSRange range )
{
    CGMutablePathRef subpath = CGPathCreateMutable();
    for (NSUInteger i = 0; i < range.length; i++) {
        FBBezierElement element = CGPath_FBElementAtIndex(path, range.location + i);
        if ( i == 0 )
            CGPathMoveToPoint(subpath, NULL, element.point.x, element.point.y);
        else
            CGPath_FBAppendElement(subpath, element);
    }
    return subpath;
}


void CGPath_FBAppendPath ( CGMutablePathRef path, CGPathRef otherPath )
{
    NSUInteger elementCount = CGPath_FBElementCount(path);
    FBBezierElement previousElement = (elementCount > 0
                                       ? CGPath_FBElementAtIndex(path, elementCount - 1)
                                       : (FBBezierElement){});
    
    NSUInteger otherElementCount = CGPath_FBElementCount(otherPath);
    for (NSUInteger i = 0; i < otherElementCount; i++) {
        FBBezierElement element = CGPath_FBElementAtIndex(otherPath, i);
        
        // If the first element is a move to where we left off, skip it
        if ( element.kind == kCGPathElementMoveToPoint ) {
            if ( CGPointEqualToPoint(element.point, previousElement.point) )
                continue;
            else
                element.kind = kCGPathElementAddLineToPoint; // change it to a line to
        }
        
        CGPath_FBAppendElement(path, element);
        previousElement = element;
    }
}


void CGPath_FBAppendElement ( CGMutablePathRef path, FBBezierElement element )
{
    switch (element.kind) {
        case kCGPathElementMoveToPoint:
            CGPathMoveToPoint(path, NULL, element.point.x, element.point.y);
            break;
        case kCGPathElementAddLineToPoint:
            CGPathAddLineToPoint(path, NULL, element.point.x, element.point.y);
            break;
        case kCGPathElementAddCurveToPoint:
            CGPathAddCurveToPoint(path, NULL,
                                  element.controlPoints[0].x, element.controlPoints[0].y,
                                  element.controlPoints[1].x, element.controlPoints[1].y,
                                  element.point.x, element.point.y);
            break;
        case kCGPathElementCloseSubpath:
            CGPathCloseSubpath(path);
            break;
        case kCGPathElementAddQuadCurveToPoint:
        default:
            break;
    }
}


#pragma mark -


void CGPath_FBElementAtIndex_ApplierFunction ( void *info, const CGPathElement *element )
{
    NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *)info;
    NSUInteger targetIndex = [dictionary[@"targetIndex"] unsignedIntegerValue];
    NSUInteger currentIndex = [dictionary[@"currentIndex"] unsignedIntegerValue] + 1;
    dictionary[@"currentIndex"] = @( currentIndex );

    if (targetIndex != currentIndex)
    {
        return;
    }
    
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    
    // Determine number of points for element type.
    NSUInteger pointCount = 0;
    switch (type)
    {
        case kCGPathElementMoveToPoint:
            pointCount = 1;
            break;
            
        case kCGPathElementAddLineToPoint:
            pointCount = 1;
            break;
            
        case kCGPathElementAddQuadCurveToPoint:
            pointCount = 2;
            break;
            
        case kCGPathElementAddCurveToPoint:
            pointCount = 3;
            break;
            
        case kCGPathElementCloseSubpath:
            pointCount = 0;
            break;
            
        default:
            return;
    }
    
    // Serialize points.
    NSData *pointsData = [NSData dataWithBytes:points
                                        length:(pointCount * sizeof(CGPoint))];
    
    // Package type and points.
    dictionary[@"type"]   = @( type );
    dictionary[@"points"] = pointsData;
}


NSUInteger CGPath_FBElementCount ( CGPathRef path )
{
    NSUInteger count = 0;
    CGPathApply(path, &count, CGPath_FBElementCount_ApplierFunction);
    return count;
}


void CGPath_FBElementCount_ApplierFunction ( void *info, const CGPathElement *element )
{
    NSUInteger *count = (NSUInteger *)info;
    (*count)++;
}
