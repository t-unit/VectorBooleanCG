//
//  CanvasController.h
//  VectorBoolean
//
//  Created by Martin Winter on 03.08.12.
//  Copyright (c) 2012 Martin Winter. All rights reserved.
//


// This class encapsulates most of the former functionality of MyDocument.


@class Canvas;


typedef NS_ENUM(unsigned int, FBShapesTag)
{
    FBShapesTagSomeOverlap = 0,
    FBShapesTagCircleInRectangle,
    FBShapesTagRectangleInCircle,
    FBShapesTagCircleOnRectangle,
    FBShapesTagHoleyRectangleWithRectangle,
    FBShapesTagCircleOnTwoRectangles,
    FBShapesTagCircleOverlappingCircle,
    FBShapesTagComplexShapes,
    FBShapesTagComplexShapes2,
    FBShapesTagTriangleInsideRectangle,
    FBShapesTagDiamondOverlappingRectangle,
    FBShapesTagDiamondInsideRectangle,
    FBShapesTagNonOverlappingContours,
    FBShapesTagMoreNonOverlappingContours,
    FBShapesTagConcentricContours,
    FBShapesTagMoreConcentricContours,
    FBShapesTagOverlappingHole,
    FBShapesTagHoleOverlappingHole,
    FBShapesTagCurvyShapeOverlappingRectangle
};


typedef NS_ENUM(unsigned int, FBOperationTag)
{
    FBOperationTagReset = 0,
    FBOperationTagUnion,
    FBOperationTagIntersect,
    FBOperationTagDifference,
    FBOperationTagJoin
};


typedef NS_ENUM(unsigned int, FBOptionTag)
{
    FBOptionTagToggleControlPoints = 0,
    FBOptionTagToggleIntersections
};


@interface CanvasController : NSObject

@property (strong) Canvas *canvas;
@property (assign, readonly) BOOL showsPoints;
@property (assign, readonly) BOOL showsIntersections;

+ (NSArray *)shapeTitles;

- (void)resetWithTag:(FBShapesTag)tag;

- (void)makeUnion;
- (void)makeIntersect;
- (void)makeDifference;
- (void)makeJoin;

- (void)togglePoints;
- (void)toggleIntersections;

@end
