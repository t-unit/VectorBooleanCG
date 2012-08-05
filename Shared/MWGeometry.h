//
//  MWGeometry.h
//  VectorBoolean
//
//  Created by Martin Winter on 05.08.12.
//  Copyright (c) 2012 Martin Winter. All rights reserved.
//

#ifndef VectorBoolean_MWGeometry_h
#define VectorBoolean_MWGeometry_h

#include <math.h>
#include <stdbool.h>

#include <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <CoreGraphics/CoreGraphics.h>
#else
#import <ApplicationServices/ApplicationServices.h>
#endif


// These are 64-bit replacements for the CGGeometry types. Unfortunately,
// CGFloat is only 32 bits on iOS, which causes precision problems when
// calculating intersections between paths.

typedef double MWFloat;

typedef struct MWPoint {
    MWFloat x;
    MWFloat y;
} MWPoint;

typedef struct {
    MWFloat width;
    MWFloat height;
}  MWSize;

typedef struct {
    MWPoint origin;
    MWSize size;
}  MWRect;


static inline MWPoint MWPointMake(MWFloat x, MWFloat y);
static inline MWPoint MWPointMake(MWFloat x, MWFloat y)
{
    MWPoint p; p.x = x; p.y = y; return p;
}


static inline MWSize MWSizeMake(MWFloat width, MWFloat height);
static inline MWSize MWSizeMake(MWFloat width, MWFloat height)
{
    MWSize size; size.width = width; size.height = height; return size;
}


static inline MWRect MWRectMake(MWFloat x, MWFloat y, MWFloat width, MWFloat height);
static inline MWRect MWRectMake(MWFloat x, MWFloat y, MWFloat width, MWFloat height)
{
    MWRect rect;
    rect.origin.x = x; rect.origin.y = y;
    rect.size.width = width; rect.size.height = height;
    return rect;
}


static inline MWPoint MWPointZeroMake();
static inline MWPoint MWPointZeroMake()
{
    MWPoint p; p.x = 0; p.y = 0; return p;
}


static inline bool MWPointEqualToPoint(MWPoint p1, MWPoint p2);
static inline bool MWPointEqualToPoint(MWPoint p1, MWPoint p2)
{
    return (p1.x == p2.x && p1.y == p2.y);
}


static inline CGPoint MWPointToCGPoint(MWPoint p);
static inline CGPoint MWPointToCGPoint(MWPoint p)
{
    return CGPointMake((CGFloat)p.x, (CGFloat)p.y);
}


static inline MWPoint MWPointFromCGPoint(CGPoint p);
static inline MWPoint MWPointFromCGPoint(CGPoint p)
{
    return MWPointMake((MWFloat)p.x, (MWFloat)p.y);
}


static inline MWRect MWRectZeroMake();
static inline MWRect MWRectZeroMake()
{
    MWRect r; r.origin.x = 0; r.origin.y = 0; r.size.width = 0; r.size.height = 0; return r;
}


static inline bool MWRectEqualToRect(MWRect r1, MWRect r2);
static inline bool MWRectEqualToRect(MWRect r1, MWRect r2)
{
    return (r1.origin.x == r2.origin.x && r1.origin.y == r2.origin.y && r1.size.width == r2.size.width && r1.size.height == r2.size.height);
}


static inline CGRect MWRectToCGRect(MWRect r);
static inline CGRect MWRectToCGRect(MWRect r)
{
    return CGRectMake((CGFloat)r.origin.x, (CGFloat)r.origin.y, (CGFloat)r.size.width, (CGFloat)r.size.height);
}


static inline MWRect MWRectFromCGRect(CGRect r);
static inline MWRect MWRectFromCGRect(CGRect r)
{
    return MWRectMake((MWFloat)r.origin.x, (MWFloat)r.origin.y, (MWFloat)r.size.width, (MWFloat)r.size.height);
}


static inline MWFloat MWRectGetMinX(MWRect r);
static inline MWFloat MWRectGetMinX(MWRect r)
{
    return r.origin.x;
}


static inline MWFloat MWRectGetMaxX(MWRect r);
static inline MWFloat MWRectGetMaxX(MWRect r)
{
    return r.origin.x + r.size.width;
}


static inline MWFloat MWRectGetMinY(MWRect rect);
static inline MWFloat MWRectGetMinY(MWRect rect)
{
    return rect.origin.y;
}


static inline MWFloat MWRectGetMaxY(MWRect rect);
static inline MWFloat MWRectGetMaxY(MWRect rect)
{
    return rect.origin.y + rect.size.height;
}


static inline MWFloat MWRectGetWidth(MWRect rect);
static inline MWFloat MWRectGetWidth(MWRect rect)
{
    return fabs(rect.size.width);
}


static inline MWFloat MWRectGetHeight(MWRect rect);
static inline MWFloat MWRectGetHeight(MWRect rect)
{
    return fabs(rect.size.height);
}


#endif
