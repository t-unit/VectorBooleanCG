//
//  CGPath_Utilities.m
//  VectorBoolean
//
//  Created by Martin Winter on 02.08.12.
//  Based on work by Andrew Finnell of Fortunate Bear, LLC.
//  Copyright (c) 2012 Martin Winter. All rights reserved.
//

#include "CGPath_Utilities.h"


void CGPath_MWElementAtIndex_ApplierFunction ( void *info, const CGPathElement *element );
void CGPath_MWElementCount_ApplierFunction ( void *info, const CGPathElement *element );
void CGPath_MWLog_ApplierFunction ( void *info, const CGPathElement *element );


CGPoint CGPath_FBPointAtIndex ( CGPathRef path, NSUInteger index )
{
    return CGPath_FBElementAtIndex(path, index).point;
}


FBBezierElement CGPath_FBElementAtIndex ( CGPathRef path, NSUInteger index )
{
    FBBezierElement element = {};
    
    // Use CGPathApply in lieu of -[NSBezierPath elementAtIndex:associatedPoints:].
    NSMutableDictionary *dictionary = [@{ @"currentIndex" : @( 0 ), @"targetIndex" : @( index ) } mutableCopy];
    CGPathApply(path, (__bridge void *)(dictionary), CGPath_MWElementAtIndex_ApplierFunction);
    
    // Note: Apparently, subscripting does not work with mutable collections
    // in iOS 5 (it does in iOS 6).
    NSNumber *typeNumber = [dictionary objectForKey:@"type"];
    if (!typeNumber)
    {
        return element;
    }
    
    element.kind = (CGPathElementType)[typeNumber intValue];
    CGPoint *points = (CGPoint *)[(NSData *)[dictionary objectForKey:@"points"] bytes];

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
            NSLog(@"%s  Encountered unhandled element type (quad curve)", __PRETTY_FUNCTION__);
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
    NSUInteger elementCount = CGPath_MWElementCount(path);
    FBBezierElement previousElement = (elementCount > 0
                                       ? CGPath_FBElementAtIndex(path, elementCount - 1)
                                       : (FBBezierElement){});
    
    NSUInteger otherElementCount = CGPath_MWElementCount(otherPath);
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


void CGPath_MWElementAtIndex_ApplierFunction ( void *info, const CGPathElement *element )
{
    NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *)info;
    NSUInteger currentIndex = [[dictionary objectForKey:@"currentIndex"] unsignedIntegerValue];
    NSUInteger targetIndex = [[dictionary objectForKey:@"targetIndex"] unsignedIntegerValue];

    if (targetIndex != currentIndex)
    {
        [dictionary setObject:@( currentIndex + 1 ) forKey:@"currentIndex"];
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
            pointCount = 1; // This must be one (as opposed to when logging)!
            break;
            
        default:
            return;
    }
    
    // Serialize points.
    NSData *pointsData = [NSData dataWithBytes:points
                                        length:(pointCount * sizeof(CGPoint))];
    
    // Package type and points.
    [dictionary setObject:@( type ) forKey:@"type"];
    [dictionary setObject:pointsData forKey:@"points"];

    [dictionary setObject:@( currentIndex + 1 ) forKey:@"currentIndex"];
}


NSUInteger CGPath_MWElementCount ( CGPathRef path )
{
    NSUInteger count = 0;
    CGPathApply(path, &count, CGPath_MWElementCount_ApplierFunction);
    return count;
}


void CGPath_MWElementCount_ApplierFunction ( void *info, const CGPathElement *element )
{
    NSUInteger *count = (NSUInteger *)info;
    (*count)++;
}


NSString * CGPath_MWLog ( CGPathRef path )
{
    NSMutableString *string = [NSMutableString stringWithFormat:@"CGPath <%#llx>", (u_int64_t)path];
    
    CGRect bounds = CGPathGetPathBoundingBox(path);
    [string appendFormat:@"\n  Bounds: {{%f, %f}, {%f, %f}}",
     bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height];
    
    CGRect controlBounds = CGPathGetBoundingBox(path);
    [string appendFormat:@"\n  Control point bounds: {{%f, %f}, {%f, %f}}",
     controlBounds.origin.x, controlBounds.origin.y, controlBounds.size.width, controlBounds.size.height];
    
    CGPathApply(path, (__bridge void *)(string), CGPath_MWLog_ApplierFunction);
    return string;
}


void CGPath_MWLog_ApplierFunction ( void *info, const CGPathElement *element )
{
    NSMutableString *string = (__bridge NSMutableString *)info;
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    
    NSUInteger pointCount = 0;
    NSString *command = @"";
    switch (type)
    {
        case kCGPathElementMoveToPoint:
            pointCount = 1;
            command = @"moveto";
            break;
            
        case kCGPathElementAddLineToPoint:
            pointCount = 1;
            command = @"lineto";
            break;
            
        case kCGPathElementAddQuadCurveToPoint:
            pointCount = 2;
            command = @"quadcurveto";
            break;
            
        case kCGPathElementAddCurveToPoint:
            pointCount = 3;
            command = @"curveto";
            break;
            
        case kCGPathElementCloseSubpath:
            pointCount = 0;
            command = @"closepath";
            break;
            
        default:
            return;
    }
    
    [string appendString:@"\n    "];
    
    for (NSUInteger pointIndex = 0; pointIndex < pointCount; pointIndex++)
    {
        [string appendFormat:@"%f %f ", points[pointIndex].x, points[pointIndex].y];
    }
    
    [string appendString:command];
}
