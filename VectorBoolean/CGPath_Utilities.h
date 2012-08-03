//
//  CGPath_Utilities.h
//  VectorBoolean
//
//  Created by Martin Winter on 02.08.12.
//  Copyright (c) 2012 Fortunate Bear, LLC. All rights reserved.
//

#ifndef VectorBoolean_CGPath_Utilities_h
#define VectorBoolean_CGPath_Utilities_h

#if TARGET_OS_IPHONE
#import <CoreGraphics/CoreGraphics.h>
#else
#import <ApplicationServices/ApplicationServices.h>
#endif


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


NSUInteger CGPath_FBElementCount (
    CGPathRef path
);

NSString * CGPath_FBLog (
    CGPathRef path
);


#endif
