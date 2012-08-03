//
//  Canvas.m
//  VectorBoolean
//
//  Created by Andrew Finnell on 5/31/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

#import "Canvas.h"
#import "CGPath_Utilities.h"
#import "FBBezierCurve.h"
#import "FBBezierIntersection.h"

static CGRect BoxFrame(CGPoint point)
{
    return CGRectMake(floorf(point.x - 2) - 0.5, floorf(point.y - 2) - 0.5, 5, 5);
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

- (void) drawRect:(CGRect)dirtyRect
{
    // TODO: get current context depending on platform!
    
    //CGRect cgRect = NSRectToCGRect(dirtyRect);
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
    // Draw on a background
    [[NSColor whiteColor] set];
    CGContextFillRect(context, dirtyRect);
    
    // Draw on the objects
    for (NSDictionary *object in _paths) {
        CGColorRef color = (__bridge CGColorRef)([object objectForKey:@"color"]);
        CGPathRef path = (__bridge CGPathRef)([object objectForKey:@"path"]);
        CGContextSetFillColorWithColor(context, color);
        CGContextAddPath(context, path);
        CGContextFillPath(context);
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
                [[NSColor orangeColor] set];
                CGContextStrokeRect(context, BoxFrame(element.point));
                if ( element.kind == kCGPathElementAddCurveToPoint ) {
                    [[NSColor blackColor] set];
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
                        [[NSColor purpleColor] set];
                    else
                        [[NSColor greenColor] set];
                    CGPathRef circle = CGPathCreateWithEllipseInRect(BoxFrame(intersection.location), NULL);
                    CGContextAddPath(context, circle);
                    CGContextStrokePath(context);
                    CGPathRelease(circle);
                }
            }
        }
    }
}

@end
