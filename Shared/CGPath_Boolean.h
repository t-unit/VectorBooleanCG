//
//  CGPath_Boolean.h
//  VectorBoolean
//
//  Created by Martin Winter on 02.08.12.
//  Based on work by Andrew Finnell of Fortunate Bear, LLC.
//  Copyright (c) 2012 Martin Winter. All rights reserved.
//

#ifndef VectorBoolean_CGPath_Boolean_h
#define VectorBoolean_CGPath_Boolean_h

#if TARGET_OS_IPHONE
#import <CoreGraphics/CoreGraphics.h>
#else
#import <ApplicationServices/ApplicationServices.h>
#endif


CGPathRef CGPath_FBCreateUnion (
    CGPathRef path,
    CGPathRef otherPath
);

CGPathRef CGPath_FBCreateIntersect (
    CGPathRef path,
    CGPathRef otherPath
);

CGPathRef CGPath_FBCreateDifference (
    CGPathRef path,
    CGPathRef otherPath
);

CGPathRef CGPath_FBCreateXOR (
    CGPathRef path,
    CGPathRef otherPath
);


#endif
