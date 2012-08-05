//
//  Canvas.m
//  VectorBoolean
//
//  Created by Andrew Finnell on 5/31/11.
//  Adapted for cross-platform use by Martin Winter on 2012-08-03.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

#import "Canvas.h"
#import "CGPath_Utilities.h"
#import "FBBezierCurve.h"
#import "FBBezierIntersection.h"


#if TARGET_OS_IPHONE
#define COLOR_CLASS     UIColor
#else
#define COLOR_CLASS     NSColor
#endif


static CGRect BoxFrame(CGPoint point)
{
    return CGRectMake(floor(point.x - 2) - 0.5, floor(point.y - 2) - 0.5, 5, 5);
}

@implementation Canvas

@synthesize showPoints=_showPoints;
@synthesize showIntersections=_showIntersections;

- (id)init
{
    self = [super init];
    if (self) {
        _paths = [[NSMutableArray alloc] initWithCapacity:3];
        _showPoints = YES;
        _showIntersections = YES;
        
        //NSLog(@"%s  size of CGFloat: %lu", __PRETTY_FUNCTION__, sizeof(CGFloat));
        //NSLog(@"%s  size of double: %lu", __PRETTY_FUNCTION__, sizeof(double));
    }
    
    return self;
}

- (void) addPath:(CGPathRef)path withColor:(CGColorRef)color
{
    NSDictionary *object = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)(path), @"path", color, @"color", nil];
    [_paths addObject:object];
}

- (NSUInteger) numberOfPaths
{
    return [_paths count];
}

- (CGPathRef) pathAtIndex:(NSUInteger)index
{
    NSDictionary *object = [_paths objectAtIndex:index];
    return (__bridge CGPathRef)([object objectForKey:@"path"]);
}

- (void) clear
{
    [_paths removeAllObjects];
}

- (void) drawRect:(CGRect)dirtyRect inContext:(CGContextRef)context
{
    // On iOS, flip vertically.
#if TARGET_OS_IPHONE
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0, dirtyRect.size.height); // Assume dirtyRect to be equal to the view’s height.
    CGContextScaleCTM(context, 1.0, -1.0);
#endif
    
    // Draw on a background
    [[COLOR_CLASS whiteColor] set];
    CGContextFillRect(context, dirtyRect);
    
    // Draw on the objects
    for (NSDictionary *object in _paths) {
        CGColorRef color = (__bridge CGColorRef)([object objectForKey:@"color"]);
        CGPathRef path = (__bridge CGPathRef)([object objectForKey:@"path"]);
        CGContextSetFillColorWithColor(context, color);
        CGContextAddPath(context, path);

        // The algorithms in this project require the even-odd fill rule. Since
        // the fill rule is not part of CGPath objects, we must set it
        // explicitly when filling.
        CGContextEOFillPath(context);
    }    
    
    // Draw on the end and control points
    if ( _showPoints ) {
        CGContextSetLineWidth(context, 1.0);
        CGContextSetLineCap(context, kCGLineCapButt);
        CGContextSetLineJoin(context, kCGLineJoinMiter);

        for (NSDictionary *object in _paths) {
            CGPathRef path = (__bridge CGPathRef)([object objectForKey:@"path"]);
            
            NSUInteger elementCount = CGPath_MWElementCount(path);
            for (NSInteger i = 0; i < elementCount; i++) {
                FBBezierElement element = CGPath_FBElementAtIndex(path, i);
                [[COLOR_CLASS orangeColor] set];
                CGContextStrokeRect(context, BoxFrame(element.point));
                if ( element.kind == kCGPathElementAddCurveToPoint ) {
                    [[COLOR_CLASS blackColor] set];
                    CGContextStrokeRect(context, BoxFrame(element.controlPoints[0]));
                    CGContextStrokeRect(context, BoxFrame(element.controlPoints[1]));
                }
            }
        }
    }

    // If we have exactly two objects, show where they intersect
    if ( _showIntersections && [_paths count] == 2 ) {
        CGPathRef path1 = (__bridge CGPathRef)([[_paths objectAtIndex:0] objectForKey:@"path"]);
        CGPathRef path2 = (__bridge CGPathRef)([[_paths objectAtIndex:1] objectForKey:@"path"]);
        NSArray *curves1 = [FBBezierCurve bezierCurvesFromBezierPath:path1];
        NSArray *curves2 = [FBBezierCurve bezierCurvesFromBezierPath:path2];
        
        for (FBBezierCurve *curve1 in curves1) {
            for (FBBezierCurve *curve2 in curves2) {
                NSArray *intersections = [curve1 intersectionsWithBezierCurve:curve2];
                for (FBBezierIntersection *intersection in intersections) {
                    if ( intersection.isTangent )
                        [[COLOR_CLASS purpleColor] set];
                    else
                        [[COLOR_CLASS greenColor] set];
                    CGPathRef circle = CGPathCreateWithEllipseInRect(BoxFrame(MWPointToCGPoint(intersection.location)), NULL);
                    CGContextAddPath(context, circle);
                    CGContextStrokePath(context);
                    CGPathRelease(circle);
                }
            }
        }
    }

#if TARGET_OS_IPHONE
    CGContextRestoreGState(context);
#endif
}

@end
