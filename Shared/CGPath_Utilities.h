//
//  CGPath_Utilities.h
//  VectorBoolean
//
//  Created by Martin Winter on 02.08.12.
//  Based on work by Andrew Finnell of Fortunate Bear, LLC.
//  Copyright (c) 2012 Martin Winter. All rights reserved.
//

#ifndef VectorBoolean_CGPath_Utilities_h
#define VectorBoolean_CGPath_Utilities_h

#if TARGET_OS_IPHONE
#import <CoreGraphics/CoreGraphics.h>
#else
#import <ApplicationServices/ApplicationServices.h>
#endif

#import "MWGeometry.h"


typedef struct {
    CGPathElementType kind;
    CGPoint point;
    CGPoint controlPoints[2];
} FBBezierElement;


CGPoint CGPath_FBPointAtIndex (
    CGPathRef path,
    NSUInteger index
);

FBBezierElement CGPath_FBElementAtIndex (
    CGPathRef path,
    NSUInteger index
);


CGPathRef CGPath_FBCreateSubpathWithRange (
    CGPathRef path,
    NSRange range
);


void CGPath_FBAppendPath (
    CGMutablePathRef path,
    CGPathRef otherPath
);

void CGPath_FBAppendElement (
    CGMutablePathRef path,
    FBBezierElement element
);


NSUInteger CGPath_MWElementCount (
    CGPathRef path
);

NSString * CGPath_MWLog (
    CGPathRef path
);


#endif
