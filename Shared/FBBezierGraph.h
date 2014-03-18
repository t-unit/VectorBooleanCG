//
//  FBBezierGraph.h
//  VectorBoolean
//
//  Created by Andrew Finnell on 6/15/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

#import "MWGeometry.h"

// FBBezierGraph is more or less an exploded version of an NSBezierPath, and
//  the two can be converted between easily. FBBezierGraph allows boolean
//  operations to be performed by allowing the curves to be annotated with
//  extra information such as where intersections happen.
@interface FBBezierGraph : NSObject {
    NSMutableArray *_contours;
    MWRect _bounds;
}

+ (id) bezierGraph;
+ (id) bezierGraphWithBezierPath:(CGPathRef)path;
- (id) initWithBezierPath:(CGPathRef)path;

- (FBBezierGraph *) unionWithBezierGraph:(FBBezierGraph *)graph;
- (FBBezierGraph *) intersectWithBezierGraph:(FBBezierGraph *)graph;
- (FBBezierGraph *) differenceWithBezierGraph:(FBBezierGraph *)graph;
- (FBBezierGraph *) xorWithBezierGraph:(FBBezierGraph *)graph;

- (CGPathRef) newBezierPath;

@end
