//
//  FBBezierCurve.m
//  VectorBoolean
//
//  Created by Andrew Finnell on 6/6/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

#import "FBBezierCurve.h"
#import "CGPath_Utilities.h"
#import "FBGeometry.h"
#import "FBBezierIntersection.h"
#import "MWPointValue.h"

//////////////////////////////////////////////////////////////////////////////////
// Normalized lines
//
typedef struct FBNormalizedLine {
    MWFloat a; // * x +
    MWFloat b; // * y +
    MWFloat c; // constant
} FBNormalizedLine;

// Create a normalized line such that computing the distance from it is quick.
//  See:    http://softsurfer.com/Archive/algorithm_0102/algorithm_0102.htm#Distance%20to%20an%20Infinite%20Line
//          http://www.cs.mtu.edu/~shene/COURSES/cs3621/NOTES/geometry/basic.html
//
static FBNormalizedLine FBNormalizedLineMake(MWPoint point1, MWPoint point2)
{
    FBNormalizedLine line = { point1.y - point2.y, point2.x - point1.x, point1.x * point2.y - point2.x * point1.y };
    MWFloat distance = sqrt(line.b * line.b + line.a * line.a);
    line.a /= distance;
    line.b /= distance;
    line.c /= distance;
    return line;
}

static MWFloat FBNormalizedLineDistanceFromPoint(FBNormalizedLine line, MWPoint point)
{
    return line.a * point.x + line.b * point.y + line.c;
}

//////////////////////////////////////////////////////////////////////////////////
// Parameter ranges
//
FBRange FBRangeMake(MWFloat minimum, MWFloat maximum)
{
    FBRange range = { minimum, maximum };
    return range;
}

BOOL FBRangeHasConverged(FBRange range, NSUInteger places)
{
    MWFloat factor = pow(10.0, places);
    NSInteger minimum = (NSInteger)(range.minimum * factor);
    NSInteger maxiumum = (NSInteger)(range.maximum * factor);
    return minimum == maxiumum;
}

MWFloat FBRangeGetSize(FBRange range)
{
    return range.maximum - range.minimum;
}

MWFloat FBRangeAverage(FBRange range)
{
    return (range.minimum + range.maximum) / 2.0;
}

MWFloat FBRangeScaleNormalizedValue(FBRange range, MWFloat value)
{
    return (range.maximum - range.minimum) * value + range.minimum;
}

//////////////////////////////////////////////////////////////////////////////////
// Helper functions
//

// The three points are a counter-clockwise turn if the return value is greater than 0,
//  clockwise if less than 0, or colinear if 0.
static MWFloat CounterClockwiseTurn(MWPoint point1, MWPoint point2, MWPoint point3)
{
    // We're calculating the signed area of the triangle formed by the three points. Well,
    //  almost the area of the triangle -- we'd need to divide by 2. But since we only
    //  care about the direction (i.e. the sign) dividing by 2 is an unnecessary step.
    // See http://mathworld.wolfram.com/TriangleArea.html for the signed area of a triangle.
    return (point2.x - point1.x) * (point3.y - point1.y) - (point2.y - point1.y) * (point3.x - point1.x);
}

// Calculate if and where the given line intersects the horizontal line at y.
static BOOL LineIntersectsHorizontalLine(MWPoint startPoint, MWPoint endPoint, MWFloat y, MWPoint *intersectPoint)
{
    // Do a quick test to see if y even falls on the startPoint,endPoint line
    if ( y < MIN(startPoint.y, endPoint.y) || y > MAX(startPoint.y, endPoint.y) )
        return NO;
    
    // There's an intersection here somewhere
    if ( startPoint.x == endPoint.x )
        *intersectPoint = MWPointMake(startPoint.x, y);
    else {
        MWFloat slope = (endPoint.y - startPoint.y) / (endPoint.x - startPoint.x);
        *intersectPoint = MWPointMake((y - startPoint.y) / slope + startPoint.x, y);
    }
    
    return YES;
}

static MWPoint BezierWithPoints(NSUInteger degree, MWPoint *bezierPoints, MWFloat parameter, MWPoint *leftCurve, MWPoint *rightCurve)
{
    // Calculate a point on the bezier curve passed in, specifically the point at parameter.
    //  We're using De Casteljau's algorithm, which not only calculates the point at parameter
    //  in a numerically stable way, it also computes the two resulting bezier curves that
    //  would be formed if the original were split at the parameter specified.
    //
    // See: http://www.cs.mtu.edu/~shene/COURSES/cs3621/NOTES/spline/Bezier/de-casteljau.html
    //  for an explaination of De Casteljau's algorithm.
    
    // bezierPoints, leftCurve, rightCurve will have a length of degree + 1. 
    // degree is the order of the bezier path, which will be cubic (3) most of the time.
    
    // With this algorithm we start out with the points in the bezier path. 
    MWPoint points[4] = {}; // we assume we'll never get more than a cubic bezier
    for (NSUInteger i = 0; i <= degree; i++)
        points[i] = bezierPoints[i];
    
    // If the caller is asking for the resulting bezier curves, start filling those in
    if ( leftCurve != nil )
        leftCurve[0] = points[0];
    if ( rightCurve != nil )
        rightCurve[degree] = points[degree];
        
    for (NSUInteger k = 1; k <= degree; k++) {
        for (NSUInteger i = 0; i <= (degree - k); i++) {
            points[i].x = (1.0 - parameter) * points[i].x + parameter * points[i + 1].x;
            points[i].y = (1.0 - parameter) * points[i].y + parameter * points[i + 1].y;            
        }
        
        if ( leftCurve != nil )
            leftCurve[k] = points[0];
        if ( rightCurve != nil )
            rightCurve[degree - k] = points[degree - k];
    }
    
    // The point in the curve at parameter ends up in points[0]
    return points[0];
}

//////////////////////////////////////////////////////////////////////////////////
// FBBezierCurve
//
// The main purpose of this class is to compute the intersections of two bezier
//  curves. It does this using the bezier clipping algorithm, described in
//  "Curve intersection using Bezier clipping" by TW Sederberg and T Nishita.
//  http://cagd.cs.byu.edu/~tom/papers/bezclip.pdf
//
@interface FBBezierCurve ()

- (FBNormalizedLine) regularFatLineBounds:(FBRange *)range;
- (FBNormalizedLine) perpendicularFatLineBounds:(FBRange *)range;

- (FBRange) clipWithFatLine:(FBNormalizedLine)fatLine bounds:(FBRange)bounds;
- (NSArray *) splitCurveAtParameter:(MWFloat)t;
- (NSArray *) convexHull;
- (FBBezierCurve *) bezierClipWithBezierCurve:(FBBezierCurve *)curve original:(FBBezierCurve *)originalCurve rangeOfOriginal:(FBRange *)originalRange intersects:(BOOL *)intersects;
- (NSArray *) intersectionsWithBezierCurve:(FBBezierCurve *)curve usRange:(FBRange *)usRange themRange:(FBRange *)themRange originalUs:(FBBezierCurve *)originalUs originalThem:(FBBezierCurve *)originalThem;
- (MWFloat) refineParameter:(MWFloat)parameter forPoint:(MWPoint)point;

@property (readonly, getter = isPoint) BOOL point;

@end

@implementation FBBezierCurve

@synthesize endPoint1=_endPoint1;
@synthesize controlPoint1=_controlPoint1;
@synthesize controlPoint2=_controlPoint2;
@synthesize endPoint2=_endPoint2;

+ (NSArray *) bezierCurvesFromBezierPath:(CGPathRef)path
{
    // Helper method to easily convert a bezier path into an array of FBBezierCurves. Very straight forward,
    //  only lines are a special case.
    
    MWPoint lastPoint = MWPointZeroMake();
    NSUInteger elementCount = CGPath_MWElementCount(path);
    NSMutableArray *bezierCurves = [NSMutableArray arrayWithCapacity:elementCount];
    
    for (NSUInteger i = 0; i < elementCount; i++) {
        FBBezierElement element = CGPath_FBElementAtIndex(path, i);
        
        switch (element.kind) {
            case kCGPathElementMoveToPoint:
                lastPoint = MWPointFromCGPoint(element.point);
                break;
                
            case kCGPathElementAddLineToPoint: {
                // Convert lines to bezier curves as well. Just set control point to be in the line formed
                //  by the end points
                [bezierCurves addObject:[FBBezierCurve bezierCurveWithLineStartPoint:lastPoint endPoint:MWPointFromCGPoint(element.point)]];
                
                lastPoint = MWPointFromCGPoint(element.point);
                break;
            }
                
            case kCGPathElementAddCurveToPoint:
                [bezierCurves addObject:[FBBezierCurve bezierCurveWithEndPoint1:lastPoint
                                                                  controlPoint1:MWPointFromCGPoint(element.controlPoints[0])
                                                                  controlPoint2:MWPointFromCGPoint(element.controlPoints[1])
                                                                      endPoint2:MWPointFromCGPoint(element.point)]];
                
                lastPoint = MWPointFromCGPoint(element.point);
                break;
                
            case kCGPathElementCloseSubpath:
                lastPoint = MWPointZeroMake();
                break;
            
            case kCGPathElementAddQuadCurveToPoint:
            default:
                break;
        }
    }
    
    return bezierCurves;
}

+ (id) bezierCurveWithLineStartPoint:(MWPoint)startPoint endPoint:(MWPoint)endPoint
{
    return [[FBBezierCurve alloc] initWithLineStartPoint:startPoint endPoint:endPoint];
}

+ (id) bezierCurveWithEndPoint1:(MWPoint)endPoint1 controlPoint1:(MWPoint)controlPoint1 controlPoint2:(MWPoint)controlPoint2 endPoint2:(MWPoint)endPoint2
{
    return [[FBBezierCurve alloc] initWithEndPoint1:endPoint1 controlPoint1:controlPoint1 controlPoint2:controlPoint2 endPoint2:endPoint2];
}

- (id) initWithEndPoint1:(MWPoint)endPoint1 controlPoint1:(MWPoint)controlPoint1 controlPoint2:(MWPoint)controlPoint2 endPoint2:(MWPoint)endPoint2
{
    self = [super init];
    
    if ( self != nil ) {
        _endPoint1 = endPoint1;
        _controlPoint1 = controlPoint1;
        _controlPoint2 = controlPoint2;
        _endPoint2 = endPoint2;
    }
    
    return self;
}

- (id) initWithLineStartPoint:(MWPoint)startPoint endPoint:(MWPoint)endPoint
{
    self = [super init];
    
    if ( self != nil ) {
        // Convert the line into a bezier curve to keep our intersection algorithm general (i.e. only
        //  has to deal with curves, not lines). As long as the control points are colinear with the
        //  end points, it'll be a line. But for consistency sake, we put the control points inside
        //  the end points, 1/3 of the total distance away from their respective end point.
        MWFloat distance = FBDistanceBetweenPoints(startPoint, endPoint);
        MWPoint leftTangent = FBNormalizePoint(FBSubtractPoint(endPoint, startPoint));
        _controlPoint1 = FBAddPoint(startPoint, FBUnitScalePoint(leftTangent, distance / 3.0));
        _controlPoint2 = FBAddPoint(startPoint, FBUnitScalePoint(leftTangent, 2.0 * distance / 3.0));
        _endPoint1 = startPoint;
        _endPoint2 = endPoint;
    }
    
    return self;
}

- (NSArray *) intersectionsWithBezierCurve:(FBBezierCurve *)curve
{
    FBRange usRange = FBRangeMake(0, 1);
    FBRange themRange = FBRangeMake(0, 1);
    return [self intersectionsWithBezierCurve:curve usRange:&usRange themRange:&themRange originalUs:self originalThem:curve];
}

- (NSArray *) intersectionsWithBezierCurve:(FBBezierCurve *)curve usRange:(FBRange *)usRange themRange:(FBRange *)themRange originalUs:(FBBezierCurve *)originalUs originalThem:(FBBezierCurve *)originalThem
{
    // This is the main work loop. At a high level this method sits in a loop and removes sections (ranges) of the two bezier curves that it knows
    //  don't intersect (how it knows that is covered in the appropriate method). The idea is to whittle the curves down to the point where they
    //  do intersect. When the range where they intersect converges (i.e. matches to 6 decimal places) or there are more than 500 attempts, the loop
    //  stops. A special case is when we're not able to remove at least 20% of the curves on a given interation. In that case we assume there are likely
    //  multiple intersections, so we divide one of curves in half, and recurse on the two halves.
    
    static const NSUInteger places = 6; // How many decimals place to calculate the solution out to
    static const NSUInteger maxIterations = 500; // how many iterations to allow before we just give up
    static const MWFloat minimumChangeNeeded = 0.20; // how much to clip off for a given iteration minimum before we subdivide the curve

    FBBezierCurve *us = self; // us is self, but clipped down to where the intersection is
    FBBezierCurve *them = curve; // them is the other curve we're intersecting with, but clipped down to where the intersection is
    FBBezierCurve *previousUs = us;
    FBBezierCurve *previousThem = them;
    
    // Don't check for convergence until we actually see if we intersect or not. i.e. Make sure we go through at least once, otherwise the results
    //  don't mean anything. Be sure to stop as soon as either range converges, otherwise calculations for the other range goes funky because one
    //  curve is essentially a point.
    NSUInteger iterations = 0;
    while ( iterations < maxIterations && ((iterations == 0) || (!FBRangeHasConverged(*usRange, places) && !FBRangeHasConverged(*themRange, places))) ) {
        // Remember what the current range is so we can calculate how much it changed later
        FBRange previousUsRange = *usRange;
        FBRange previousThemRange = *themRange;
        
        // Remove the range from ourselves that doesn't intersect with them. If the other curve is already a point, use the previous iteration's
        //  copy of them so calculations still work.
        BOOL intersects = NO;
        us = [us bezierClipWithBezierCurve:them.isPoint ? previousThem : them original:originalUs rangeOfOriginal:usRange intersects:&intersects];

        if ( !intersects )
        {
            return [NSArray array]; // If they don't intersect at all stop now
        }

        // Remove the range of them that doesn't intersect with us
        them = [them bezierClipWithBezierCurve:us.isPoint ? previousUs : us original:originalThem rangeOfOriginal:themRange intersects:&intersects];
        
        if ( !intersects )
        {
            return [NSArray array];  // If they don't intersect at all stop now
        }
        
        // If either curve has been reduced to a point, stop now even if the range hasn't properly converged. Once curves become points, the math
        //  falls apart.
        if ( us.isPoint || them.isPoint )
        {
            break;
        }
        
        // See if either of curves ranges is reduced by less than 20%.
        MWFloat percentChangeInUs = (FBRangeGetSize(previousUsRange) - FBRangeGetSize(*usRange)) / FBRangeGetSize(previousUsRange);
        MWFloat percentChangeInThem = (FBRangeGetSize(previousThemRange) - FBRangeGetSize(*themRange)) / FBRangeGetSize(previousThemRange);

        if ( percentChangeInUs < minimumChangeNeeded && percentChangeInThem < minimumChangeNeeded ) {
            // We're not converging fast enough, likely because there are multiple intersections here. So
            //  divide and conquer. Divide the longer curve in half, and recurse
            if ( FBRangeGetSize(*usRange) > FBRangeGetSize(*themRange) ) {
                // Since our remaining range is longer, split the remains of us in half at the midway point
                FBRange usRange1 = FBRangeMake(usRange->minimum, (usRange->minimum + usRange->maximum) / 2.0);
                FBBezierCurve *us1 = [originalUs subcurveWithRange:usRange1];
                FBRange themRangeCopy1 = *themRange; // make a local copy because it'll get modified when we recurse

                FBRange usRange2 = FBRangeMake((usRange->minimum + usRange->maximum) / 2.0, usRange->maximum);
                FBBezierCurve *us2 = [originalUs subcurveWithRange:usRange2];
                FBRange themRangeCopy2 = *themRange; // make a local copy because it'll get modified when we recurse
                
                // Compute the intersections between the two halves of us and them
                NSArray *intersections1 = [us1 intersectionsWithBezierCurve:them usRange:&usRange1 themRange:&themRangeCopy1 originalUs:originalUs originalThem:originalThem];
                NSArray *intersections2 = [us2 intersectionsWithBezierCurve:them usRange:&usRange2 themRange:&themRangeCopy2 originalUs:originalUs originalThem:originalThem];

                return [intersections1 arrayByAddingObjectsFromArray:intersections2];
            } else {
                // Since their remaining range is longer, split the remains of them in half at the midway point
                FBRange themRange1 = FBRangeMake(themRange->minimum, (themRange->minimum + themRange->maximum) / 2.0);
                FBBezierCurve *them1 = [originalThem subcurveWithRange:themRange1];
                FBRange usRangeCopy1 = *usRange;  // make a local copy because it'll get modified when we recurse

                FBRange themRange2 = FBRangeMake((themRange->minimum + themRange->maximum) / 2.0, themRange->maximum);
                FBBezierCurve *them2 = [originalThem subcurveWithRange:themRange2];
                FBRange usRangeCopy2 = *usRange;  // make a local copy because it'll get modified when we recurse

                // Compute the intersections between the two halves of them and us
                NSArray *intersections1 = [us intersectionsWithBezierCurve:them1 usRange:&usRangeCopy1 themRange:&themRange1 originalUs:originalUs originalThem:originalThem];
                NSArray *intersections2 = [us intersectionsWithBezierCurve:them2 usRange:&usRangeCopy2 themRange:&themRange2 originalUs:originalUs originalThem:originalThem];

                return [intersections1 arrayByAddingObjectsFromArray:intersections2];
            }
        }
        
        iterations++;
        previousUs = us;
        previousThem = them;
    }
    
    // It's possible that one of the curves has converged, but the other hasn't. Since the math becomes wonky once a curve becomes a point,
    //  the loop stops as soon as either curve converges. However for our purposes we need _both_ curves to converge; that is we need
    //  the parameter for each curve where they intersect. Fortunately, since one curve did converge we know the 2D point where they converge,
    //  plus we have a reasonable approximation for the parameter for the curve that didn't. That means we can use Newton's method to refine
    //  the parameter of the curve that did't converge.
    if ( FBRangeHasConverged(*usRange, places) && !FBRangeHasConverged(*themRange, places) ) {
        // Refine the them range since it didn't converge
        MWPoint intersectionPoint = [originalUs pointAtParameter:usRange->minimum leftBezierCurve:nil rightBezierCurve:nil];
        MWFloat refinedParameter = FBRangeAverage(*themRange); // Although the range didn't converge, it should be a reasonable approximation which is all Newton needs

        for (NSUInteger i = 0; i < 3; i++)
            refinedParameter = [originalThem refineParameter:refinedParameter forPoint:intersectionPoint];

        themRange->minimum = refinedParameter;
        themRange->maximum = refinedParameter;
    } else if ( !FBRangeHasConverged(*usRange, places) && FBRangeHasConverged(*themRange, places) ) {
        // Refine the us range since it didn't converge
        MWPoint intersectionPoint = [originalThem pointAtParameter:themRange->minimum leftBezierCurve:nil rightBezierCurve:nil];
        MWFloat refinedParameter = FBRangeAverage(*usRange); // Although the range didn't converge, it should be a reasonable approximation which is all Newton needs

        for (NSUInteger i = 0; i < 3; i++)
            refinedParameter = [originalUs refineParameter:refinedParameter forPoint:intersectionPoint];

        usRange->minimum = refinedParameter;
        usRange->maximum = refinedParameter;        
    }
    
    // Return the final intersection, which we represent by the original curves and the parameters where they intersect. The parameter values are useful
    //  later in the boolean operations, plus it allows us to do lazy calculations.
    return [NSArray arrayWithObject:[FBBezierIntersection intersectionWithCurve1:originalUs parameter1:usRange->minimum curve2:originalThem parameter2:themRange->minimum]];
}

- (FBBezierCurve *) bezierClipWithBezierCurve:(FBBezierCurve *)curve original:(FBBezierCurve *)originalCurve rangeOfOriginal:(FBRange *)originalRange intersects:(BOOL *)intersects
{
    // This method does the clipping of self. It removes the parts of self that we can determine don't intersect
    //  with curve. It'll return the clipped version of self, update originalRange which corresponds to the range
    //  on the original curve that the return value represents. Finally, it'll set the intersects out parameter
    //  to yes or no depending on if the curves intersect or not.
    
    // Clipping works as follows:
    //  Draw a line through the two endpoints of the other curve, which we'll call the fat line. Measure the 
    //  signed distance between the control points on the other curve and the fat line. The distance from the line
    //  will give us the fat line bounds. Any part of our curve that lies further away from the fat line than the 
    //  fat line bounds we know can't intersect with the other curve, and thus can be removed.
    
    // We actually use two different fat lines. The first one uses the end points of the other curve, and the second
    //  one is perpendicular to the first. Most of the time, the first fat line will clip off more, but sometimes the
    //  second proves to be a better fat line in that it clips off more. We use both in order to converge more quickly.
    
    // Compute the regular fat line using the end points, then compute the range that could still possibly intersect
    //  with the other curve
    FBRange fatLineBounds = {};
    FBNormalizedLine fatLine = [curve regularFatLineBounds:&fatLineBounds];
    FBRange regularClippedRange = [self clipWithFatLine:fatLine bounds:fatLineBounds];
    // A range of [1, 0] is a special sentinel value meaning "they don't intersect". If they don't, bail early to save time
    if ( regularClippedRange.minimum == 1.0 && regularClippedRange.maximum == 0.0 ) {
        *intersects = NO;
        return self;
    }
    
    // Just in case the regular fat line isn't good enough, try the perpendicular one
    FBRange perpendicularLineBounds = {};
    FBNormalizedLine perpendicularLine = [curve perpendicularFatLineBounds:&perpendicularLineBounds];
    FBRange perpendicularClippedRange = [self clipWithFatLine:perpendicularLine bounds:perpendicularLineBounds];
    if ( perpendicularClippedRange.minimum == 1.0 && perpendicularClippedRange.maximum == 0.0 ) {
        *intersects = NO;
        return self;
    }
    
    // Combine to form Voltron. Take the intersection of the regular fat line range and the perpendicular one.
    FBRange clippedRange = FBRangeMake(MAX(regularClippedRange.minimum, perpendicularClippedRange.minimum), MIN(regularClippedRange.maximum, perpendicularClippedRange.maximum));    
    
    // Right now the clipped range is relative to ourself, not the original curve. So map the newly clipped range onto the original range
    FBRange newRange = FBRangeMake(FBRangeScaleNormalizedValue(*originalRange, clippedRange.minimum), FBRangeScaleNormalizedValue(*originalRange, clippedRange.maximum));    
    *originalRange = newRange;
    *intersects = YES;
    
    // Actually divide the curve, but be sure to use the original curve. This helps with errors building up.
    return [originalCurve subcurveWithRange:*originalRange];
}

- (FBNormalizedLine) regularFatLineBounds:(FBRange *)range
{
    // Create the fat line based on the end points
    FBNormalizedLine line = FBNormalizedLineMake(_endPoint1, _endPoint2);
    
    // Compute the bounds of the fat line. The fat line bounds should entirely encompass the
    //  bezier curve. Since we know the convex hull entirely compasses the curve, just take
    //  all four points that define this cubic bezier curve. Compute the signed distances of
    //  each of the end and control points from the fat line, and that will give us the bounds.
    
    // In this case, we know that the end points are on the line, thus their distances will be 0.
    //  So we can skip computing those and just use 0.
    MWFloat controlPoint1Distance = FBNormalizedLineDistanceFromPoint(line, _controlPoint1);
    MWFloat controlPoint2Distance = FBNormalizedLineDistanceFromPoint(line, _controlPoint2);    
    MWFloat min = MIN(controlPoint1Distance, MIN(controlPoint2Distance, 0.0));
    MWFloat max = MAX(controlPoint1Distance, MAX(controlPoint2Distance, 0.0));
        
    *range = FBRangeMake(min, max);
    
    return line;
}

- (FBNormalizedLine) perpendicularFatLineBounds:(FBRange *)range
{
    // Create a fat line that's perpendicular to the line created by the two end points.
    MWPoint normal = FBLineNormal(_endPoint1, _endPoint2);
    MWPoint startPoint = FBLineMidpoint(_endPoint1, _endPoint2);
    MWPoint endPoint = FBAddPoint(startPoint, normal);
    FBNormalizedLine line = FBNormalizedLineMake(startPoint, endPoint);
    
    // Compute the bounds of the fat line. The fat line bounds should entirely encompass the
    //  bezier curve. Since we know the convex hull entirely compasses the curve, just take
    //  all four points that define this cubic bezier curve. Compute the signed distances of
    //  each of the end and control points from the fat line, and that will give us the bounds.
    MWFloat controlPoint1Distance = FBNormalizedLineDistanceFromPoint(line, _controlPoint1);
    MWFloat controlPoint2Distance = FBNormalizedLineDistanceFromPoint(line, _controlPoint2);
    MWFloat point1Distance = FBNormalizedLineDistanceFromPoint(line, _endPoint1);
    MWFloat point2Distance = FBNormalizedLineDistanceFromPoint(line, _endPoint2);

    MWFloat min = MIN(controlPoint1Distance, MIN(controlPoint2Distance, MIN(point1Distance, point2Distance)));
    MWFloat max = MAX(controlPoint1Distance, MAX(controlPoint2Distance, MAX(point1Distance, point2Distance)));
    
    *range = FBRangeMake(min, max);
    
    return line;
}

- (FBRange) clipWithFatLine:(FBNormalizedLine)fatLine bounds:(FBRange)bounds
{
    // This method computes the range of self that could possibly intersect with the fat line passed in (and thus with the curve enclosed by the fat line).
    //  To do that, we first compute the signed distance of all our points (end and control) from the fat line, and map those onto a bezier curve at
    //  evenly spaced intervals from [0..1]. The parts of the distance bezier that fall inside of the fat line bounds, correspond to the parts of ourself
    //  that could potentially intersect with the other curve. Ideally, we'd calculate where the distance bezier intersected the horizontal lines representing
    //  the fat line bounds. However, computing those intersections is hard and costly. So instead we'll compute the convex hull, and intersect those lines
    //  with the fat line bounds. The intersection with the lowest x coordinate will be the minimum, and the intersection with the highest x coordinate will
    //  be the maximum.
    
    // The convex hull (for cubic beziers) is the four points that define the curve. A useful property of the convex hull is that the entire curve lies
    //  inside of it.
    
    // First calculate bezier curve points distance from the fat line that's clipping us
    FBBezierCurve *distanceBezier = [FBBezierCurve bezierCurveWithEndPoint1:MWPointMake(0, FBNormalizedLineDistanceFromPoint(fatLine, _endPoint1)) controlPoint1:MWPointMake(1.0/3.0, FBNormalizedLineDistanceFromPoint(fatLine, _controlPoint1)) controlPoint2:MWPointMake(2.0/3.0, FBNormalizedLineDistanceFromPoint(fatLine, _controlPoint2)) endPoint2:MWPointMake(1.0, FBNormalizedLineDistanceFromPoint(fatLine, _endPoint2))];
    
    NSArray *convexHull = [distanceBezier convexHull]; // the convex hull can be anywhere from 2 to 4 points.
    
    // Find intersections of convex hull with the fat line bounds
    FBRange range = FBRangeMake(1.0, 0.0);
    for (NSUInteger i = 0; i < [convexHull count]; i++) {
        // Pull out the current line on the convex hull
        NSUInteger indexOfNext = i < ([convexHull count] - 1) ? i + 1 : 0;
        MWPoint startPoint = [(MWPointValue *)[convexHull objectAtIndex:i] point];
        MWPoint endPoint = [(MWPointValue *)[convexHull objectAtIndex:indexOfNext] point];
        MWPoint intersectionPoint = MWPointZeroMake();
        
        // See if the segment of the convex hull intersects with the minimum fat line bounds
        if ( LineIntersectsHorizontalLine(startPoint, endPoint, bounds.minimum, &intersectionPoint) ) {
            if ( intersectionPoint.x < range.minimum )
                range.minimum = intersectionPoint.x;
            if ( intersectionPoint.x > range.maximum )
                range.maximum = intersectionPoint.x;
        }
        // This is a very special case that I really wish I could get rid of. If perfectly horizontal and perfectly vertical lines intersect at both of their end points,
        //  the convex hull becomes a horizontal line on top of the minimum and maximum lines, which makes the line intersection calculation wonky. At this point, we
        //  throw our hands up and just say "we don't know where in here they intersect". If we don't do this, we end up saying they don't intersect at all, which could
        //  be wrong.
        if ( [convexHull count] == 2 && FBAreValuesClose(startPoint.y, endPoint.y) && FBAreValuesClose(startPoint.y, bounds.minimum) && !FBAreValuesClose(bounds.minimum, bounds.maximum) )
            range = FBRangeMake(0, 1);
        
        // See if this segment of the convex hull intersects with the maximum fat line bounds
        if ( LineIntersectsHorizontalLine(startPoint, endPoint, bounds.maximum, &intersectionPoint) ) {
            if ( intersectionPoint.x < range.minimum )
                range.minimum = intersectionPoint.x;
            if ( intersectionPoint.x > range.maximum )
                range.maximum = intersectionPoint.x;
        }
        // See the corresponding comment for the minimum intersection
        if ( [convexHull count] == 2 && FBAreValuesClose(startPoint.y, endPoint.y) && FBAreValuesClose(startPoint.y, bounds.maximum) && !FBAreValuesClose(bounds.minimum, bounds.maximum) )
            range = FBRangeMake(0, 1);
        
        // We want to be able to refine t even if the convex hull lies completely inside the bounds. This
        //  also allows us to be able to use range of [1..0] as a sentinel value meaning the convex hull
        //  lies entirely outside of bounds, and the curves don't intersect.
        if ( startPoint.y < bounds.maximum && startPoint.y > bounds.minimum ) {
            if ( startPoint.x < range.minimum )
                range.minimum = startPoint.x;
            if ( startPoint.x > range.maximum )
                range.maximum = startPoint.x;
        }
    }
    return range;
}

- (FBBezierCurve *) subcurveWithRange:(FBRange)range
{
    // Return a bezier curve representing the parameter range specified. We do this by splitting
    //  twice: once on the minimum, the splitting the result of that on the maximum.
    NSArray *curves1 = [self splitCurveAtParameter:range.minimum];
    FBBezierCurve *upperCurve = [curves1 objectAtIndex:1];
    if ( range.minimum == 1.0 )
        return upperCurve; // avoid the divide by zero below
    // We need to adjust the maximum parameter to fit on the new curve before we split again
    MWFloat adjustedMaximum = (range.maximum - range.minimum) / (1.0 - range.minimum);
    NSArray *curves2 = [upperCurve splitCurveAtParameter:adjustedMaximum];
    return [curves2 objectAtIndex:0];
}

- (MWPoint) pointAtParameter:(MWFloat)parameter leftBezierCurve:(FBBezierCurve **)leftBezierCurve rightBezierCurve:(FBBezierCurve **)rightBezierCurve
{    
    // This method is a simple wrapper around the BezierWithPoints() helper function. It computes the 2D point at the given parameter,
    //  and (optionally) the resulting curves that splitting at the parameter would create.
    
    MWPoint points[4] = { _endPoint1, _controlPoint1, _controlPoint2, _endPoint2 };
    MWPoint leftCurve[4] = {};
    MWPoint rightCurve[4] = {};

    MWPoint point = BezierWithPoints(3, points, parameter, leftCurve, rightCurve);
    
    if ( leftBezierCurve != nil )
        *leftBezierCurve = [FBBezierCurve bezierCurveWithEndPoint1:leftCurve[0] controlPoint1:leftCurve[1] controlPoint2:leftCurve[2] endPoint2:leftCurve[3]];
    if ( rightBezierCurve != nil )
        *rightBezierCurve = [FBBezierCurve bezierCurveWithEndPoint1:rightCurve[0] controlPoint1:rightCurve[1] controlPoint2:rightCurve[2] endPoint2:rightCurve[3]];
    return point;
}

- (MWFloat) refineParameter:(MWFloat)parameter forPoint:(MWPoint)point
{
    // Use Newton's Method to refine our parameter. In general, that formula is:
    //
    //  parameter = parameter - f(parameter) / f'(parameter)
    //
    // In our case:
    //
    //  f(parameter) = (Q(parameter) - point) * Q'(parameter) = 0
    //
    // Where Q'(parameter) is tangent to the curve at Q(parameter) and orthogonal to [Q(parameter) - P]
    //
    // Taking the derivative gives us:
    //
    //  f'(parameter) = (Q(parameter) - point) * Q''(parameter) + Q'(parameter) * Q'(parameter)
    //
    
    MWPoint bezierPoints[4] = {_endPoint1, _controlPoint1, _controlPoint2, _endPoint2};
    
    // Compute Q(parameter)
    MWPoint qAtParameter = BezierWithPoints(3, bezierPoints, parameter, nil, nil);
    
    // Compute Q'(parameter)
    MWPoint qPrimePoints[3] = {};
    for (NSUInteger i = 0; i < 3; i++) {
        qPrimePoints[i].x = (bezierPoints[i + 1].x - bezierPoints[i].x) * 3.0;
        qPrimePoints[i].y = (bezierPoints[i + 1].y - bezierPoints[i].y) * 3.0;
    }
    MWPoint qPrimeAtParameter = BezierWithPoints(2, qPrimePoints, parameter, nil, nil);
    
    // Compute Q''(parameter)
    MWPoint qPrimePrimePoints[2] = {};
    for (NSUInteger i = 0; i < 2; i++) {
        qPrimePrimePoints[i].x = (qPrimePoints[i + 1].x - qPrimePoints[i].x) * 2.0;
        qPrimePrimePoints[i].y = (qPrimePoints[i + 1].y - qPrimePoints[i].y) * 2.0;        
    }
    MWPoint qPrimePrimeAtParameter = BezierWithPoints(1, qPrimePrimePoints, parameter, nil, nil);
    
    // Compute f(parameter) and f'(parameter)
    MWPoint qMinusPoint = FBSubtractPoint(qAtParameter, point);
    MWFloat fAtParameter = FBDotMultiplyPoint(qMinusPoint, qPrimeAtParameter);
    MWFloat fPrimeAtParameter = FBDotMultiplyPoint(qMinusPoint, qPrimePrimeAtParameter) + FBDotMultiplyPoint(qPrimeAtParameter, qPrimeAtParameter);
    
    // Newton's method!
    return parameter - (fAtParameter / fPrimeAtParameter);
}

- (NSArray *) splitCurveAtParameter:(MWFloat)parameter
{
    // Convience method that returns the result of splitting at the given parameter
    FBBezierCurve *leftCurve = nil;
    FBBezierCurve *rightCurve = nil;
    [self pointAtParameter:parameter leftBezierCurve:&leftCurve rightBezierCurve:&rightCurve];
    return [NSArray arrayWithObjects:leftCurve, rightCurve, nil];
}

- (NSArray *) convexHull
{
    // Compute the convex hull for this bezier curve. The convex hull is made up of the end and control points.
    //  The hard part is determine the order they go in, and if any are inside or colinear with the convex hull.
    
    // We're using the Graham Scan algorithm to determine the convex hull. It finds the points that form the outside
    //  bounds of the curve.
    //
    // See also: http://en.wikipedia.org/wiki/Graham_scan
    //  and     http://softsurfer.com/Archive/algorithm_0109/algorithm_0109.htm
    
    // Start with all the end and control points in any order.
    NSMutableArray *points = [NSMutableArray arrayWithObjects:
                              [[MWPointValue alloc] initWithPoint:_endPoint1],
                              [[MWPointValue alloc] initWithPoint:_controlPoint1],
                              [[MWPointValue alloc] initWithPoint:_controlPoint2],
                              [[MWPointValue alloc] initWithPoint:_endPoint2],
                              nil];

    // First, find the point that is on the bottom right, and move it to the first position in our array.
    NSUInteger lowestIndex = 0;
    MWPoint lowestValue = [(MWPointValue *)[points objectAtIndex:0] point];
    for (NSUInteger i = 0; i < [points count]; i++) {
        MWPoint point = [(MWPointValue *)[points objectAtIndex:i] point];
        if ( point.y < lowestValue.y || (point.y == lowestValue.y && point.x > lowestValue.x) ) {
            lowestIndex = i;
            lowestValue = point;
        }
    }
    [points exchangeObjectAtIndex:0 withObjectAtIndex:lowestIndex];

    // Sort the points by the angle they form with the horizontal line on the lowest point, ascending.
    //  Remember any redundant (i.e. colinear) points so we can remove them later.
    NSMutableArray *pointsToDelete = [NSMutableArray arrayWithCapacity:4];
    [points sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        MWPoint point1 = [(MWPointValue *)obj1 point];
        MWPoint point2 = [(MWPointValue *)obj2 point];
        
        // Special case: Our pivot value (lowestValue, at index 0) should stay at the lowest
        if ( MWPointEqualToPoint(lowestValue, point1) )
            return NSOrderedAscending;
        if ( MWPointEqualToPoint(lowestValue, point2) )
            return NSOrderedDescending;
        
        // We don't care about the actual angle value, just their values relative to each other.
        //  Compute the signed area of the triangle the points form, as a quick estimate of
        //  where the points lie relative to each other.
        MWFloat area = CounterClockwiseTurn(lowestValue, point1, point2);
        if ( FBAreValuesClose(area, 0.0) ) {
            // Ugh, the points are colinear. That means at least one of the points is going
            //  to be redundant, specifically the one closest to the pivot point. Remember
            //  the redundant point so it can be deleted later.
            MWFloat distance1 = FBDistanceBetweenPoints(point1, lowestValue);
            MWFloat distance2 = FBDistanceBetweenPoints(point2, lowestValue);
            // The three points are colinear, so base it on distance instead
            if ( distance1 < distance2 ) {
                [pointsToDelete addObject:obj1];
                return NSOrderedAscending;
            } else if ( distance1 > distance2 ) {
                [pointsToDelete addObject:obj2];
                return NSOrderedDescending;
            }
            [pointsToDelete addObject:obj1];            
            return NSOrderedSame;
        } else if ( area < 0.0 )
            // point2 is to the right of the line formed by lowestValue, point1
            return NSOrderedDescending;
        //else if ( area > 0.0 )
        // point2 is left of the line formed by lowestValue, point1
        return NSOrderedAscending;                    
    }];
    // Remove any colinear points
    for (NSValue *value in pointsToDelete)
        [points removeObject:value];
    
    // We want to create an array of points where we only ever turn left.
    // Push the first two points onto the top of the results stack. Consider the point at i
    //  in the points array. If it causes the results array to turn left (counter clock wise),
    //  then add it to the results, then move on to consider the next point in points array.
    //  If it causes the results array to turn right, then remove the top of the results stack
    //  and try the point at i again.
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:4];
    [results addObject:[points objectAtIndex:0]];
    [results addObject:[points objectAtIndex:1]];
    NSUInteger i = 2;
    NSUInteger pointsCount = [points count];

    while ( i < pointsCount ) {
        // TODO: sometimes there is only one point left in results, which leads to a crash. This never happens on OS X!

        MWPoint lastPoint = [(MWPointValue *)[results lastObject] point];
        MWPoint nextToLastPoint = [(MWPointValue *)[results objectAtIndex:[results count] - 2] point];
        MWPoint pointUnderConsideration = [(MWPointValue *)[points objectAtIndex:i] point];
        MWFloat area = CounterClockwiseTurn(nextToLastPoint, lastPoint, pointUnderConsideration);

        if ( area > 0.0 ) {
            // Turning left is good, so keep going
            [results addObject:[points objectAtIndex:i]];
            i++;
        } else {
            // Turning right is bad, so remove the top point
            [results removeLastObject];
        }
    }
    
    return results;
}

- (BOOL) isPoint
{
    // If the two end points are close together, then we're a point. Ignore the control
    //  points.
    return FBArePointsClose(_endPoint1, _endPoint2);
}

- (void) round
{
    // Round the end and control points to the nearest integral value.
    _endPoint1 = FBRoundPoint(_endPoint1);
    _controlPoint1 = FBRoundPoint(_controlPoint1);
    _controlPoint2 = FBRoundPoint(_controlPoint2);
    _endPoint2 = FBRoundPoint(_endPoint2);
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"<%@ (%f, %f)-[%f, %f] curve to [%f, %f]-(%f, %f)>", 
            NSStringFromClass([self class]), 
            _endPoint1.x, _endPoint1.y, _controlPoint1.x, _controlPoint1.y,
            _controlPoint2.x, _controlPoint2.y, _endPoint2.x, _endPoint2.y];
}

@end
