//
//  Canvas.h
//  VectorBoolean
//
//  Created by Andrew Finnell on 5/31/11.
//  Adapted for cross-platform use by Martin Winter on 2012-08-03.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Canvas : NSObject {
    NSMutableArray *_paths;
    BOOL _showPoints;
    BOOL _showIntersections;
}

- (void) addPath:(CGPathRef)path withColor:(CGColorRef)color;
- (void) clear;

- (NSUInteger) numberOfPaths;
- (CGPathRef) pathAtIndex:(NSUInteger)index;

- (void) drawRect:(CGRect)dirtyRect inContext:(CGContextRef)context;

@property BOOL showPoints;
@property BOOL showIntersections;

@end
