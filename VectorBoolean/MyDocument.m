//
//  MyDocument.m
//  VectorBoolean
//
//  Created by Andrew Finnell on 5/31/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

#import "MyDocument.h"
#import "CanvasView.h"
#import "Canvas.h"
#import "CGPath_Boolean.h"

#import "CGPath_Utilities.h"

@interface MyDocument ()

- (void) addSomeOverlap;
- (void) addCircleInRectangle;
- (void) addRectangleInCircle;
- (void) addCircleOnRectangle;
- (void) addHoleyRectangleWithRectangle;
- (void) addCircleOnTwoRectangles;
- (void) addCircleOverlappingCircle;
- (void) addComplexShapes;
- (void) addComplexShapes2;
- (void) addTriangleInsideRectangle;
- (void) addDiamondOverlappingRectangle;
- (void) addDiamondInsideRectangle;
- (void) addNonOverlappingContours;
- (void) addMoreNonOverlappingContours;
- (void) addConcentricContours;
- (void) addMoreConcentricContours;
- (void) addOverlappingHole;
- (void) addHoleOverlappingHole;
- (void) addCurvyShapeOverlappingRectangle;

- (void) addRectangle:(CGRect)rect;
- (void) addCircleAtPoint:(CGPoint)center withRadius:(CGFloat)radius;
- (void) addTriangle:(CGPoint)point1 point2:(CGPoint)point2 point3:(CGPoint)point3;
- (void) addQuadrangle:(CGPoint)point1 point2:(CGPoint)point2 point3:(CGPoint)point3 point4:(CGPoint)point4;

- (void) addRectangle:(CGRect)rect toPath:(CGMutablePathRef)rectangle;
- (void) addCircleAtPoint:(CGPoint)center withRadius:(CGFloat)radius toPath:(CGMutablePathRef)circle;
- (void) addTriangle:(CGPoint)point1 point2:(CGPoint)point2 point3:(CGPoint)point3 toPath:(CGMutablePathRef)path;
- (void) addQuadrangle:(CGPoint)point1 point2:(CGPoint)point2 point3:(CGPoint)point3 point4:(CGPoint)point4 toPath:(CGMutablePathRef)path;

@end

static CGColorRef _redColor;
static CGColorRef _blueColor;

@implementation MyDocument

+ (void)initialize
{
    if (!_redColor)
    {
        _redColor = CGColorCreateGenericRGB(1.0, 0.0, 0.0, 1.0);
    }
    
    if (!_blueColor)
    {
        _blueColor = CGColorCreateGenericRGB(0.0, 0.0, 1.0, 1.0);
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        _resetAction = @selector(addSomeOverlap);
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    [self onReset:nil];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    /*
     Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
     You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
     */
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    /*
     Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
     You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
     */
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return YES;
}

- (IBAction) onReset:(id)sender
{
    [_view.canvas clear];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:_resetAction];
#pragma clang diagnostic pop
    
    [_view setNeedsDisplay:YES];
}

- (void) addSomeOverlap
{
    [self addRectangle:CGRectMake(50, 50, 300, 200)];
    [self addCircleAtPoint:CGPointMake(355, 240) withRadius:125];
}

- (void) addCircleInRectangle
{
    [self addRectangle:CGRectMake(50, 50, 350, 300)];
    [self addCircleAtPoint:CGPointMake(210, 200) withRadius:125];
}

- (void) addRectangleInCircle
{
    [self addRectangle:CGRectMake(150, 150, 150, 150)];
    [self addCircleAtPoint:CGPointMake(200, 200) withRadius:185];
}

- (void) addCircleOnRectangle
{
    [self addRectangle:CGRectMake(15, 15, 370, 370)];
    [self addCircleAtPoint:CGPointMake(200, 200) withRadius:185];
}

- (void) addHoleyRectangleWithRectangle
{
    CGMutablePathRef holeyRectangle = CGPathCreateMutable();
    [self addRectangle:CGRectMake(50, 50, 350, 300) toPath:holeyRectangle];
    [self addCircleAtPoint:CGPointMake(210, 200) withRadius:125 toPath:holeyRectangle];
    [_view.canvas addPath:holeyRectangle withColor:_blueColor];
    CGPathRelease(holeyRectangle);

    CGMutablePathRef rectangle = CGPathCreateMutable();
    [self addRectangle:CGRectMake(180, 5, 100, 400) toPath:rectangle];
    [_view.canvas addPath:rectangle withColor:_redColor];
    CGPathRelease(rectangle);
}

- (void) addCircleOnTwoRectangles
{
    CGMutablePathRef rectangles = CGPathCreateMutable();
    [self addRectangle:CGRectMake(50, 5, 100, 400) toPath:rectangles];
    [self addRectangle:CGRectMake(350, 5, 100, 400) toPath:rectangles];
    [_view.canvas addPath:rectangles withColor:_blueColor];
    
    [self addCircleAtPoint:CGPointMake(200, 200) withRadius:185];
    CGPathRelease(rectangles);
}

- (void) addCircleOverlappingCircle
{
    CGMutablePathRef circle = CGPathCreateMutable();
    [self addCircleAtPoint:CGPointMake(355, 240) withRadius:125 toPath:circle];
    [_view.canvas addPath:circle withColor:_blueColor];
    
    [self addCircleAtPoint:CGPointMake(210, 110) withRadius:100];
    CGPathRelease(circle);
}

- (void) addComplexShapes
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
    
    [_view.canvas addPath:allParts withColor:_blueColor];
    [_view.canvas addPath:intersectingParts withColor:_redColor];
    CGPathRelease(allParts);
    CGPathRelease(intersectingParts);
}

- (void) addComplexShapes2
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
    
    [_view.canvas addPath:allParts withColor:_blueColor];
    [_view.canvas addPath:intersectingParts withColor:_redColor];
    CGPathRelease(allParts);
    CGPathRelease(intersectingParts);
}

- (void) addTriangleInsideRectangle
{
    [self addRectangle:CGRectMake(100, 100, 300, 300)];
    [self addTriangle:CGPointMake(100, 400) point2:CGPointMake(400, 400) point3:CGPointMake(250, 250)];
}

- (void) addDiamondOverlappingRectangle
{
    [self addRectangle:CGRectMake(50, 50, 200, 200)];
    [self addQuadrangle:CGPointMake(50, 250) point2:CGPointMake(150, 400) point3:CGPointMake(250, 250) point4:CGPointMake(150, 100)];
}

- (void) addDiamondInsideRectangle
{
    [self addRectangle:CGRectMake(100, 100, 300, 300)];
    [self addQuadrangle:CGPointMake(100, 250) point2:CGPointMake(250, 400) point3:CGPointMake(400, 250) point4:CGPointMake(250, 100)];
}

- (void) addNonOverlappingContours
{
    [self addRectangle:CGRectMake(100, 200, 200, 200)];
    
    CGMutablePathRef circles = CGPathCreateMutable();
    [self addCircleAtPoint:CGPointMake(200, 300) withRadius:85 toPath:circles];
    [self addCircleAtPoint:CGPointMake(200, 95) withRadius:85 toPath:circles];
    [_view.canvas addPath:circles withColor:_redColor];
    CGPathRelease(circles);
}

- (void) addMoreNonOverlappingContours
{
    CGMutablePathRef rectangles = CGPathCreateMutable();
    [self addRectangle:CGRectMake(100, 200, 200, 200) toPath:rectangles];
    [self addRectangle:CGRectMake(175, 70, 50, 50) toPath:rectangles];
    [_view.canvas addPath:rectangles withColor:_blueColor];
    CGPathRelease(rectangles);

    CGMutablePathRef circles = CGPathCreateMutable();
    [self addCircleAtPoint:CGPointMake(200, 300) withRadius:85 toPath:circles];
    [self addCircleAtPoint:CGPointMake(200, 95) withRadius:85 toPath:circles];
    [_view.canvas addPath:circles withColor:_redColor];
    CGPathRelease(circles);
}

- (void) addConcentricContours
{
    CGMutablePathRef holeyRectangle = CGPathCreateMutable();
    [self addRectangle:CGRectMake(50, 50, 350, 300) toPath:holeyRectangle];
    [self addCircleAtPoint:CGPointMake(210, 200) withRadius:125 toPath:holeyRectangle];
    [_view.canvas addPath:holeyRectangle withColor:_blueColor];
    CGPathRelease(holeyRectangle);
    
    [self addCircleAtPoint:CGPointMake(210, 200) withRadius:140];
}

- (void) addMoreConcentricContours
{
    CGMutablePathRef holeyRectangle = CGPathCreateMutable();
    [self addRectangle:CGRectMake(50, 50, 350, 300) toPath:holeyRectangle];
    [self addCircleAtPoint:CGPointMake(210, 200) withRadius:125 toPath:holeyRectangle];
    [_view.canvas addPath:holeyRectangle withColor:_blueColor];
    CGPathRelease(holeyRectangle);
    
    [self addCircleAtPoint:CGPointMake(210, 200) withRadius:70];
}

- (void) addOverlappingHole
{
    CGMutablePathRef holeyRectangle = CGPathCreateMutable();
    [self addRectangle:CGRectMake(50, 50, 350, 300) toPath:holeyRectangle];
    [self addCircleAtPoint:CGPointMake(210, 200) withRadius:125 toPath:holeyRectangle];
    [_view.canvas addPath:holeyRectangle withColor:_blueColor];
    CGPathRelease(holeyRectangle);
    
    CGMutablePathRef circle = CGPathCreateMutable();
    [self addCircleAtPoint:CGPointMake(180, 180) withRadius:125 toPath:circle];
    [_view.canvas addPath:circle withColor:_redColor];
    CGPathRelease(circle);
}

- (void) addHoleOverlappingHole
{
    CGMutablePathRef holeyRectangle1 = CGPathCreateMutable();
    [self addRectangle:CGRectMake(50, 50, 350, 300) toPath:holeyRectangle1];
    [self addCircleAtPoint:CGPointMake(210, 200) withRadius:125 toPath:holeyRectangle1];
    [_view.canvas addPath:holeyRectangle1 withColor:_blueColor];
    CGPathRelease(holeyRectangle1);
    
    CGMutablePathRef holeyRectangle2 = CGPathCreateMutable();
    [self addRectangle:CGRectMake(225, 65, 160, 160) toPath:holeyRectangle2];
    [self addCircleAtPoint:CGPointMake(305, 145) withRadius:65 toPath:holeyRectangle2];
    [_view.canvas addPath:holeyRectangle2 withColor:_redColor];
    CGPathRelease(holeyRectangle2);
}

- (void) addCurvyShapeOverlappingRectangle
{
    CGMutablePathRef rectangle = CGPathCreateMutable();
    CGFloat top = 65.0 + 160.0 / 3.0;
    CGPathMoveToPoint(rectangle, NULL, 40, top);
    CGPathAddLineToPoint(rectangle, NULL, 410, top);
    CGPathAddLineToPoint(rectangle, NULL, 410, 50);
    CGPathAddLineToPoint(rectangle, NULL, 40, 50);
    CGPathAddLineToPoint(rectangle, NULL, 40, top);
    [_view.canvas addPath:rectangle withColor:_redColor];
    CGPathRelease(rectangle);

    CGMutablePathRef curveyShape = CGPathCreateMutable();
    CGPathMoveToPoint(curveyShape, NULL, 335.000000, 203.000000);
    CGPathAddCurveToPoint(curveyShape, NULL, 335.000000, 202.000000, 335.000000, 201.000000, 335.000000, 200.000000);
    CGPathAddCurveToPoint(curveyShape, NULL, 335.000000, 153.000000, 309.000000, 111.000000, 270.000000, 90.000000);
    CGPathAddCurveToPoint(curveyShape, NULL, 252.000000, 102.000000, 240.000000, 122.000000, 240.000000, 145.000000);
    CGPathAddCurveToPoint(curveyShape, NULL, 240.000000, 181.000000, 269.000000, 210.000000, 305.000000, 210.000000);
    CGPathAddCurveToPoint(curveyShape, NULL, 316.000000, 210.000000, 326.000000, 207.000000, 335.000000, 203.000000);
    [_view.canvas addPath:curveyShape withColor:_blueColor];
    CGPathRelease(curveyShape);
}

- (void) addRectangle:(CGRect)rect
{
    CGMutablePathRef rectangle = CGPathCreateMutable();
    [self addRectangle:rect toPath:rectangle];
    [_view.canvas addPath:rectangle withColor:_blueColor];
    CGPathRelease(rectangle);
}

- (void) addCircleAtPoint:(CGPoint)center withRadius:(CGFloat)radius
{
    CGMutablePathRef circle = CGPathCreateMutable();
    [self addCircleAtPoint:center withRadius:radius toPath:circle];
    [_view.canvas addPath:circle withColor:_redColor];
    CGPathRelease(circle);
}

- (void) addTriangle:(CGPoint)point1 point2:(CGPoint)point2 point3:(CGPoint)point3
{
    CGMutablePathRef triangle = CGPathCreateMutable();
    [self addTriangle:point1 point2:point2 point3:point3 toPath:triangle];
    [_view.canvas addPath:triangle withColor:_redColor];
    CGPathRelease(triangle);
}

- (void) addQuadrangle:(CGPoint)point1 point2:(CGPoint)point2 point3:(CGPoint)point3 point4:(CGPoint)point4
{
    CGMutablePathRef quandrangle = CGPathCreateMutable();
    [self addQuadrangle:point1 point2:point2 point3:point3 point4:point4 toPath:quandrangle];
    [_view.canvas addPath:quandrangle withColor:_redColor];
    CGPathRelease(quandrangle);
}

- (void) addRectangle:(CGRect)rect toPath:(CGMutablePathRef)rectangle
{
    CGPathAddRect(rectangle, NULL, rect);
}

- (void) addCircleAtPoint:(CGPoint)center withRadius:(CGFloat)radius toPath:(CGMutablePathRef)circle
{
    static const CGFloat FBMagicNumber = 0.55228475;
    CGFloat controlPointLength = radius * FBMagicNumber;
    CGPathMoveToPoint(circle, NULL, center.x - radius, center.y);
    CGPathAddCurveToPoint(circle, NULL, center.x - radius, center.y + controlPointLength, center.x - controlPointLength, center.y + radius, center.x, center.y + radius);
    CGPathAddCurveToPoint(circle, NULL, center.x + controlPointLength, center.y + radius, center.x + radius, center.y + controlPointLength, center.x + radius, center.y);
    CGPathAddCurveToPoint(circle, NULL, center.x + radius, center.y - controlPointLength, center.x + controlPointLength, center.y - radius, center.x, center.y - radius);
    CGPathAddCurveToPoint(circle, NULL, center.x - controlPointLength, center.y - radius, center.x - radius, center.y - controlPointLength, center.x - radius, center.y);
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


- (IBAction) onUnion:(id)sender
{
    [self onReset:sender];
    
    CGPathRef result = CGPath_FBCreateUnion([_view.canvas pathAtIndex:0], [_view.canvas pathAtIndex:1]);

    NSUInteger elementCount = CGPath_FBElementCount(result);
    NSLog(@"%s  elementCount: %lx", __PRETTY_FUNCTION__, elementCount);

    [_view.canvas clear];
    [_view.canvas addPath:result withColor:_blueColor];
    CGPathRelease(result);
}

- (IBAction) onIntersect:(id)sender
{
    [self onReset:sender];
    
    CGPathRef result = CGPath_FBCreateIntersect([_view.canvas pathAtIndex:0], [_view.canvas pathAtIndex:1]);
    [_view.canvas clear];
    [_view.canvas addPath:result withColor:_blueColor];
    CGPathRelease(result);
}

- (IBAction) onDifference:(id)sender // Punch
{
    [self onReset:sender];
    
    CGPathRef result = CGPath_FBCreateDifference([_view.canvas pathAtIndex:0], [_view.canvas pathAtIndex:1]);
    [_view.canvas clear];
    [_view.canvas addPath:result withColor:_blueColor];
    CGPathRelease(result);
}

- (IBAction) onJoin:(id)sender // XOR
{
    [self onReset:sender];
    
    CGPathRef result = CGPath_FBCreateXOR([_view.canvas pathAtIndex:0], [_view.canvas pathAtIndex:1]);
    [_view.canvas clear];
    [_view.canvas addPath:result withColor:_blueColor];
    CGPathRelease(result);
}

- (IBAction) onCircleOverlappingRectangle:(id)sender
{
    _resetAction = @selector(addSomeOverlap);
    [self onReset:sender];
}

- (IBAction) onCircleInRectangle:(id)sender
{
    _resetAction = @selector(addCircleInRectangle);
    [self onReset:sender];
}

- (IBAction) onRectangleInCircle:(id)sender
{
    _resetAction = @selector(addRectangleInCircle);
    [self onReset:sender];
}

- (IBAction) onCircleOnRectangle:(id)sender
{
    _resetAction = @selector(addCircleOnRectangle);
    [self onReset:sender];
}

- (IBAction) onRectangleWithHoleOverlappingRectangle:(id)sender
{
    _resetAction = @selector(addHoleyRectangleWithRectangle);
    [self onReset:sender];
}

- (IBAction) onTwoRectanglesOverlappingCircle:(id)sender
{
    _resetAction = @selector(addCircleOnTwoRectangles);
    [self onReset:sender];
}

- (IBAction) onCircleOverlappingCircle:(id)sender
{
    _resetAction = @selector(addCircleOverlappingCircle);
    [self onReset:sender];
}

- (IBAction) onComplexShapes:(id)sender
{
    _resetAction = @selector(addComplexShapes);
    [self onReset:sender];
}

- (IBAction) onComplexShapes2:(id)sender
{
    _resetAction = @selector(addComplexShapes2);
    [self onReset:sender];
}

- (IBAction) onTriangleInsideRectangle:(id)sender
{
    _resetAction = @selector(addTriangleInsideRectangle);
    [self onReset:sender];
}

- (IBAction) onDiamondOverlappingRectangle:(id)sender
{
    _resetAction = @selector(addDiamondOverlappingRectangle);
    [self onReset:sender];
}

- (IBAction) onDiamondInsideRectangle:(id)sender
{
    _resetAction = @selector(addDiamondInsideRectangle);
    [self onReset:sender];
}

- (IBAction) onNonOverlappingContours:(id)sender
{
    _resetAction = @selector(addNonOverlappingContours);
    [self onReset:sender];
}

- (IBAction) onMoreNonOverlappingContours:(id)sender
{
    _resetAction = @selector(addMoreNonOverlappingContours);
    [self onReset:sender];
}

- (IBAction) onConcentricContours:(id)sender
{
    _resetAction = @selector(addConcentricContours);
    [self onReset:sender];
}

- (IBAction) onMoreConcentricContours:(id)sender
{
    _resetAction = @selector(addMoreConcentricContours);
    [self onReset:sender];
}

- (IBAction) onCircleOverlappingHole:(id)sender
{
    _resetAction = @selector(addOverlappingHole);
    [self onReset:sender];
}

- (IBAction) onHoleOverlappingHole:(id)sender
{
    _resetAction = @selector(addHoleOverlappingHole);
    [self onReset:sender];
}

- (IBAction) onCurvyShapeOverlappingRectangle:(id)sender
{
    _resetAction = @selector(addCurvyShapeOverlappingRectangle);
    [self onReset:sender];
}

- (IBAction) onShowPoints:(id)sender
{
    _view.canvas.showPoints = !_view.canvas.showPoints;
    [_view setNeedsDisplay:YES];
}

- (IBAction) onShowIntersections:(id)sender
{
    _view.canvas.showIntersections = !_view.canvas.showIntersections;
    [_view setNeedsDisplay:YES];
}

- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem
{
    NSMenuItem *menuItem = (NSMenuItem *)anItem;
    if ( [anItem action] == @selector(onCircleOverlappingRectangle:) ) {
        [menuItem setState:_resetAction == @selector(addSomeOverlap) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onCircleInRectangle:) ) {
        [menuItem setState:_resetAction == @selector(addCircleInRectangle) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onRectangleInCircle:) ) {
        [menuItem setState:_resetAction == @selector(addRectangleInCircle) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onCircleOnRectangle:) ) {
        [menuItem setState:_resetAction == @selector(addCircleOnRectangle) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onRectangleWithHoleOverlappingRectangle:) ) {
        [menuItem setState:_resetAction == @selector(addHoleyRectangleWithRectangle) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onTwoRectanglesOverlappingCircle:) ) {
        [menuItem setState:_resetAction == @selector(addCircleOnTwoRectangles) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onCircleOverlappingCircle:) ) {
        [menuItem setState:_resetAction == @selector(addCircleOverlappingCircle) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onComplexShapes:) ) {
        [menuItem setState:_resetAction == @selector(addComplexShapes) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onComplexShapes2:) ) {
        [menuItem setState:_resetAction == @selector(addComplexShapes2) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onTriangleInsideRectangle:) ) {
        [menuItem setState:_resetAction == @selector(addTriangleInsideRectangle) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onDiamondOverlappingRectangle:) ) {
        [menuItem setState:_resetAction == @selector(addDiamondOverlappingRectangle) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onDiamondInsideRectangle:) ) {
        [menuItem setState:_resetAction == @selector(addDiamondInsideRectangle) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onNonOverlappingContours:) ) {
        [menuItem setState:_resetAction == @selector(addNonOverlappingContours) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onMoreNonOverlappingContours:) ) {
        [menuItem setState:_resetAction == @selector(addMoreNonOverlappingContours) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onConcentricContours:) ) {
        [menuItem setState:_resetAction == @selector(addConcentricContours) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onMoreConcentricContours:) ) {
        [menuItem setState:_resetAction == @selector(addMoreConcentricContours) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onCircleOverlappingHole:) ) {
        [menuItem setState:_resetAction == @selector(addOverlappingHole) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onHoleOverlappingHole:) ) {
        [menuItem setState:_resetAction == @selector(addHoleOverlappingHole) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onCurvyShapeOverlappingRectangle:) ) {
        [menuItem setState:_resetAction == @selector(addCurvyShapeOverlappingRectangle) ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onShowPoints:) ) {
        [menuItem setState:_view.canvas.showPoints ? NSOnState : NSOffState];
    } else if ( [anItem action] == @selector(onShowIntersections:) ) {
        [menuItem setState:_view.canvas.showIntersections ? NSOnState : NSOffState];
    }
    
    
    return YES;
}

@end
