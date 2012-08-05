//
//  CanvasController.m
//  VectorBoolean
//
//  Created by Martin Winter on 03.08.12.
//  Copyright (c) 2012 Fortunate Bear, LLC. All rights reserved.
//

#import "CanvasController.h"
#import "Canvas.h"
#import "CGPath_Boolean.h"
#import "CGPath_Utilities.h"


#if TARGET_OS_IPHONE
#define COLOR_CLASS     UIColor
#else
#define COLOR_CLASS     NSColor
#endif


@implementation CanvasController


+ (NSArray *)shapeTitles
{
    return @[
    @"Circle Overlapping Rectangle",
    @"Circle in Rectangle",
    @"Rectangle in Circle",
    @"Circle on Rectangle",
    @"Rectangle with Hole Overlapping Rectangle",
    @"Two rectangles Overlapping Rectangle",
    @"Circle overlapping Circle",
    @"Complex Shapes",
    @"More Complex Shapes",
    @"Triangle inside Rectangle",
    @"Diamond overlapping Rectangle",
    @"Diamond inside Rectangle",
    @"Non-overlapping Contours",
    @"More Non-overlapping Contours",
    @"Concentric Contours",
    @"More Concentric Contours",
    @"Circle Overlapping Hole",
    @"Rectangle w/hole Overlapping Rectangle w/hole",
    @"Curve Overlapping Rectangle"
    ];
}


- (BOOL)showsPoints
{
    return self.canvas.showPoints;
}


- (BOOL)showsIntersections
{
    return self.canvas.showIntersections;
}


#pragma mark -


- (void)addShapesForTag:(FBShapesTag)tag
{
    switch (tag)
    {
        case FBShapesTagSomeOverlap:
        {
            [self addRectangle:CGRectMake(50, 50, 300, 200)];
            [self addCircleAtPoint:CGPointMake(355, 240) withRadius:125];
            break;
        }
            
        case FBShapesTagCircleInRectangle:
        {
            [self addRectangle:CGRectMake(50, 50, 350, 300)];
            [self addCircleAtPoint:CGPointMake(210, 200) withRadius:125];
            break;
        }
            
        case FBShapesTagRectangleInCircle:
        {
            [self addRectangle:CGRectMake(150, 150, 150, 150)];
            [self addCircleAtPoint:CGPointMake(200, 200) withRadius:185];
            break;
        }
            
        case FBShapesTagCircleOnRectangle:
        {
            [self addRectangle:CGRectMake(15, 15, 370, 370)];
            [self addCircleAtPoint:CGPointMake(200, 200) withRadius:185];
            break;
        }
            
        case FBShapesTagHoleyRectangleWithRectangle:
        {
            CGMutablePathRef holeyRectangle = CGPathCreateMutable();
            [self addRectangle:CGRectMake(50, 50, 350, 300) toPath:holeyRectangle];
            [self addCircleAtPoint:CGPointMake(210, 200) withRadius:125 toPath:holeyRectangle];
            [self.canvas addPath:holeyRectangle withColor:[[COLOR_CLASS blueColor] CGColor]];
            CGPathRelease(holeyRectangle);
            
            CGMutablePathRef rectangle = CGPathCreateMutable();
            [self addRectangle:CGRectMake(180, 5, 100, 400) toPath:rectangle];
            [self.canvas addPath:rectangle withColor:[[COLOR_CLASS redColor] CGColor]];
            CGPathRelease(rectangle);
            break;
        }
            
        case FBShapesTagCircleOnTwoRectangles:
        {
            CGMutablePathRef rectangles = CGPathCreateMutable();
            [self addRectangle:CGRectMake(50, 5, 100, 400) toPath:rectangles];
            [self addRectangle:CGRectMake(350, 5, 100, 400) toPath:rectangles];
            [self.canvas addPath:rectangles withColor:[[COLOR_CLASS blueColor] CGColor]];
            
            [self addCircleAtPoint:CGPointMake(200, 200) withRadius:185];
            CGPathRelease(rectangles);
            break;
        }
            
        case FBShapesTagCircleOverlappingCircle:
        {
            CGMutablePathRef circle = CGPathCreateMutable();
            [self addCircleAtPoint:CGPointMake(355, 240) withRadius:125 toPath:circle];
            [self.canvas addPath:circle withColor:[[COLOR_CLASS blueColor] CGColor]];
            
            [self addCircleAtPoint:CGPointMake(210, 110) withRadius:100];
            CGPathRelease(circle);
            break;
        }
            
        case FBShapesTagComplexShapes:
        {
            CGMutablePathRef holeyRectangle = CGPathCreateMutable();
            [self addRectangle:CGRectMake(50, 50, 350, 300) toPath:holeyRectangle];
            [self addCircleAtPoint:CGPointMake(210, 200) withRadius:125 toPath:holeyRectangle];
            
            CGMutablePathRef rectangle = CGPathCreateMutable();
            [self addRectangle:CGRectMake(180, 5, 100, 400) toPath:rectangle];
            
            CGPathRef allParts = CGPath_FBCreateUnion(holeyRectangle, rectangle);
            CGPathRef intersectingParts = CGPath_FBCreateIntersect(holeyRectangle, rectangle);
            CGPathRelease(holeyRectangle);
            CGPathRelease(rectangle);
            
            [self.canvas addPath:allParts withColor:[[COLOR_CLASS blueColor] CGColor]];
            [self.canvas addPath:intersectingParts withColor:[[COLOR_CLASS redColor] CGColor]];
            CGPathRelease(allParts);
            CGPathRelease(intersectingParts);
            break;
        }
            
        case FBShapesTagComplexShapes2:
        {
            CGMutablePathRef rectangles = CGPathCreateMutable();
            [self addRectangle:CGRectMake(50, 5, 100, 400) toPath:rectangles];
            [self addRectangle:CGRectMake(350, 5, 100, 400) toPath:rectangles];
            
            CGMutablePathRef circle = CGPathCreateMutable();
            [self addCircleAtPoint:CGPointMake(200, 200) withRadius:185 toPath:circle];
            
            CGPathRef allParts = CGPath_FBCreateUnion(rectangles, circle);
            CGPathRef intersectingParts = CGPath_FBCreateIntersect(rectangles, circle);
            CGPathRelease(rectangles);
            CGPathRelease(circle);
            
            [self.canvas addPath:allParts withColor:[[COLOR_CLASS blueColor] CGColor]];
            [self.canvas addPath:intersectingParts withColor:[[COLOR_CLASS redColor] CGColor]];
            CGPathRelease(allParts);
            CGPathRelease(intersectingParts);
            break;
        }
            
        case FBShapesTagTriangleInsideRectangle:
        {
            [self addRectangle:CGRectMake(100, 100, 300, 300)];
            [self addTriangle:CGPointMake(100, 400) point2:CGPointMake(400, 400) point3:CGPointMake(250, 250)];
            break;
        }
            
        case FBShapesTagDiamondOverlappingRectangle:
        {
            [self addRectangle:CGRectMake(50, 50, 200, 200)];
            [self addQuadrangle:CGPointMake(50, 250) point2:CGPointMake(150, 400) point3:CGPointMake(250, 250) point4:CGPointMake(150, 100)];
            break;
        }
            
        case FBShapesTagDiamondInsideRectangle:
        {
            [self addRectangle:CGRectMake(100, 100, 300, 300)];
            [self addQuadrangle:CGPointMake(100, 250) point2:CGPointMake(250, 400) point3:CGPointMake(400, 250) point4:CGPointMake(250, 100)];
            break;
        }
            
        case FBShapesTagNonOverlappingContours:
        {
            [self addRectangle:CGRectMake(100, 200, 200, 200)];
            
            CGMutablePathRef circles = CGPathCreateMutable();
            [self addCircleAtPoint:CGPointMake(200, 300) withRadius:85 toPath:circles];
            [self addCircleAtPoint:CGPointMake(200, 95) withRadius:85 toPath:circles];
            [self.canvas addPath:circles withColor:[[COLOR_CLASS redColor] CGColor]];
            CGPathRelease(circles);
            break;
        }
            
        case FBShapesTagMoreNonOverlappingContours:
        {
            CGMutablePathRef rectangles = CGPathCreateMutable();
            [self addRectangle:CGRectMake(100, 200, 200, 200) toPath:rectangles];
            [self addRectangle:CGRectMake(175, 70, 50, 50) toPath:rectangles];
            [self.canvas addPath:rectangles withColor:[[COLOR_CLASS blueColor] CGColor]];
            CGPathRelease(rectangles);
            
            CGMutablePathRef circles = CGPathCreateMutable();
            [self addCircleAtPoint:CGPointMake(200, 300) withRadius:85 toPath:circles];
            [self addCircleAtPoint:CGPointMake(200, 95) withRadius:85 toPath:circles];
            [self.canvas addPath:circles withColor:[[COLOR_CLASS redColor] CGColor]];
            CGPathRelease(circles);
            break;
        }
            
        case FBShapesTagConcentricContours:
        {
            CGMutablePathRef holeyRectangle = CGPathCreateMutable();
            [self addRectangle:CGRectMake(50, 50, 350, 300) toPath:holeyRectangle];
            [self addCircleAtPoint:CGPointMake(210, 200) withRadius:125 toPath:holeyRectangle];
            [self.canvas addPath:holeyRectangle withColor:[[COLOR_CLASS blueColor] CGColor]];
            CGPathRelease(holeyRectangle);
            
            [self addCircleAtPoint:CGPointMake(210, 200) withRadius:140];
            break;
        }
            
        case FBShapesTagMoreConcentricContours:
        {
            CGMutablePathRef holeyRectangle = CGPathCreateMutable();
            [self addRectangle:CGRectMake(50, 50, 350, 300) toPath:holeyRectangle];
            [self addCircleAtPoint:CGPointMake(210, 200) withRadius:125 toPath:holeyRectangle];
            [self.canvas addPath:holeyRectangle withColor:[[COLOR_CLASS blueColor] CGColor]];
            CGPathRelease(holeyRectangle);
            
            [self addCircleAtPoint:CGPointMake(210, 200) withRadius:70];
            break;
        }
            
        case FBShapesTagOverlappingHole:
        {
            CGMutablePathRef holeyRectangle = CGPathCreateMutable();
            [self addRectangle:CGRectMake(50, 50, 350, 300) toPath:holeyRectangle];
            [self addCircleAtPoint:CGPointMake(210, 200) withRadius:125 toPath:holeyRectangle];
            [self.canvas addPath:holeyRectangle withColor:[[COLOR_CLASS blueColor] CGColor]];
            CGPathRelease(holeyRectangle);
            
            CGMutablePathRef circle = CGPathCreateMutable();
            [self addCircleAtPoint:CGPointMake(180, 180) withRadius:125 toPath:circle];
            [self.canvas addPath:circle withColor:[[COLOR_CLASS redColor] CGColor]];
            CGPathRelease(circle);
            break;
        }
            
        case FBShapesTagHoleOverlappingHole:
        {
            CGMutablePathRef holeyRectangle1 = CGPathCreateMutable();
            [self addRectangle:CGRectMake(50, 50, 350, 300) toPath:holeyRectangle1];
            [self addCircleAtPoint:CGPointMake(210, 200) withRadius:125 toPath:holeyRectangle1];
            [self.canvas addPath:holeyRectangle1 withColor:[[COLOR_CLASS blueColor] CGColor]];
            CGPathRelease(holeyRectangle1);
            
            CGMutablePathRef holeyRectangle2 = CGPathCreateMutable();
            [self addRectangle:CGRectMake(225, 65, 160, 160) toPath:holeyRectangle2];
            [self addCircleAtPoint:CGPointMake(305, 145) withRadius:65 toPath:holeyRectangle2];
            [self.canvas addPath:holeyRectangle2 withColor:[[COLOR_CLASS redColor] CGColor]];
            CGPathRelease(holeyRectangle2);
            break;
        }
            
        case FBShapesTagCurvyShapeOverlappingRectangle:
        {
            CGMutablePathRef rectangle = CGPathCreateMutable();
            CGFloat top = 65.0 + 160.0 / 3.0;
            CGPathMoveToPoint(rectangle, NULL, 40, top);
            CGPathAddLineToPoint(rectangle, NULL, 410, top);
            CGPathAddLineToPoint(rectangle, NULL, 410, 50);
            CGPathAddLineToPoint(rectangle, NULL, 40, 50);
            CGPathAddLineToPoint(rectangle, NULL, 40, top);
            [self.canvas addPath:rectangle withColor:[[COLOR_CLASS redColor] CGColor]];
            CGPathRelease(rectangle);
            
            CGMutablePathRef curveyShape = CGPathCreateMutable();
            CGPathMoveToPoint(curveyShape, NULL, 335.000000, 203.000000);
            CGPathAddCurveToPoint(curveyShape, NULL, 335.000000, 202.000000, 335.000000, 201.000000, 335.000000, 200.000000);
            CGPathAddCurveToPoint(curveyShape, NULL, 335.000000, 153.000000, 309.000000, 111.000000, 270.000000, 90.000000);
            CGPathAddCurveToPoint(curveyShape, NULL, 252.000000, 102.000000, 240.000000, 122.000000, 240.000000, 145.000000);
            CGPathAddCurveToPoint(curveyShape, NULL, 240.000000, 181.000000, 269.000000, 210.000000, 305.000000, 210.000000);
            CGPathAddCurveToPoint(curveyShape, NULL, 316.000000, 210.000000, 326.000000, 207.000000, 335.000000, 203.000000);
            [self.canvas addPath:curveyShape withColor:[[COLOR_CLASS blueColor] CGColor]];
            CGPathRelease(curveyShape);
            break;
        }
            
        default:
            break;
    }
}


- (void) addRectangle:(CGRect)rect
{
    CGMutablePathRef rectangle = CGPathCreateMutable();
    [self addRectangle:rect toPath:rectangle];
    [self.canvas addPath:rectangle withColor:[[COLOR_CLASS blueColor] CGColor]];
    CGPathRelease(rectangle);
}

- (void) addCircleAtPoint:(CGPoint)center withRadius:(CGFloat)radius
{
    CGMutablePathRef circle = CGPathCreateMutable();
    [self addCircleAtPoint:center withRadius:radius toPath:circle];
    [self.canvas addPath:circle withColor:[[COLOR_CLASS redColor] CGColor]];
    CGPathRelease(circle);
}

- (void) addTriangle:(CGPoint)point1 point2:(CGPoint)point2 point3:(CGPoint)point3
{
    CGMutablePathRef triangle = CGPathCreateMutable();
    [self addTriangle:point1 point2:point2 point3:point3 toPath:triangle];
    [self.canvas addPath:triangle withColor:[[COLOR_CLASS redColor] CGColor]];
    CGPathRelease(triangle);
}

- (void) addQuadrangle:(CGPoint)point1 point2:(CGPoint)point2 point3:(CGPoint)point3 point4:(CGPoint)point4
{
    CGMutablePathRef quadrangle = CGPathCreateMutable();
    [self addQuadrangle:point1 point2:point2 point3:point3 point4:point4 toPath:quadrangle];
    [self.canvas addPath:quadrangle withColor:[[COLOR_CLASS redColor] CGColor]];
    CGPathRelease(quadrangle);
}

- (void) addRectangle:(CGRect)rect toPath:(CGMutablePathRef)rectangle
{
    CGPathAddRect(rectangle, NULL, rect);
}

- (void) addCircleAtPoint:(CGPoint)center withRadius:(CGFloat)radius toPath:(CGMutablePathRef)circle
{
    /*
    static const CGFloat FBMagicNumber = 0.55228475;
    CGFloat controlPointLength = radius * FBMagicNumber;
    CGPathMoveToPoint(circle, NULL, center.x - radius, center.y);
    CGPathAddCurveToPoint(circle, NULL, center.x - radius, center.y + controlPointLength, center.x - controlPointLength, center.y + radius, center.x, center.y + radius);
    CGPathAddCurveToPoint(circle, NULL, center.x + controlPointLength, center.y + radius, center.x + radius, center.y + controlPointLength, center.x + radius, center.y);
    CGPathAddCurveToPoint(circle, NULL, center.x + radius, center.y - controlPointLength, center.x + controlPointLength, center.y - radius, center.x, center.y - radius);
    CGPathAddCurveToPoint(circle, NULL, center.x - controlPointLength, center.y - radius, center.x - radius, center.y - controlPointLength, center.x - radius, center.y);
     */
    
    CGRect rect = CGRectMake(center.x - radius, center.y - radius, 2.0 * radius, 2.0 * radius);
    CGPathAddEllipseInRect(circle, NULL, rect);
}

- (void) addTriangle:(CGPoint)point1 point2:(CGPoint)point2 point3:(CGPoint)point3 toPath:(CGMutablePathRef)path
{
    CGPathMoveToPoint(path, NULL, point1.x, point1.y);
    CGPathAddLineToPoint(path, NULL, point2.x, point2.y);
    CGPathAddLineToPoint(path, NULL, point3.x, point3.y);
    CGPathAddLineToPoint(path, NULL, point1.x, point1.y);
}

- (void) addQuadrangle:(CGPoint)point1 point2:(CGPoint)point2 point3:(CGPoint)point3 point4:(CGPoint)point4 toPath:(CGMutablePathRef)path
{
    CGPathMoveToPoint(path, NULL, point1.x, point1.y);
    CGPathAddLineToPoint(path, NULL, point2.x, point2.y);
    CGPathAddLineToPoint(path, NULL, point3.x, point3.y);
    CGPathAddLineToPoint(path, NULL, point4.x, point4.y);
    CGPathAddLineToPoint(path, NULL, point1.x, point1.y);
}


#pragma mark -


- (void)resetWithTag:(FBShapesTag)tag
{
    [self.canvas clear];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self addShapesForTag:tag];
#pragma clang diagnostic pop
}


- (void)makeUnion
{
    CGPathRef result = CGPath_FBCreateUnion([self.canvas pathAtIndex:0], [self.canvas pathAtIndex:1]);
    [self.canvas clear];
    [self.canvas addPath:result withColor:[[COLOR_CLASS blueColor] CGColor]];
    CGPathRelease(result);
}


- (void)makeIntersect
{
    CGPathRef result = CGPath_FBCreateIntersect([self.canvas pathAtIndex:0], [self.canvas pathAtIndex:1]);
    [self.canvas clear];
    [self.canvas addPath:result withColor:[[COLOR_CLASS blueColor] CGColor]];
    CGPathRelease(result);
}


- (void)makeDifference
{
    CGPathRef result = CGPath_FBCreateDifference([self.canvas pathAtIndex:0], [self.canvas pathAtIndex:1]);
    [self.canvas clear];
    [self.canvas addPath:result withColor:[[COLOR_CLASS blueColor] CGColor]];
    CGPathRelease(result);
}


- (void)makeJoin
{
    CGPathRef result = CGPath_FBCreateXOR([self.canvas pathAtIndex:0], [self.canvas pathAtIndex:1]);
    [self.canvas clear];
    [self.canvas addPath:result withColor:[[COLOR_CLASS blueColor] CGColor]];
    CGPathRelease(result);
}


- (void)togglePoints
{
    self.canvas.showPoints = !self.canvas.showPoints;
}


- (void)toggleIntersections
{
    self.canvas.showIntersections = !self.canvas.showIntersections;
}


@end
