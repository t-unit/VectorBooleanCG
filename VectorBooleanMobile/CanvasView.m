//
//  CanvasView.m
//  VectorBoolean
//
//  Created by Andrew Finnell on 5/31/11.
//  Adapted for cross-platform use by Martin Winter on 2012-08-03.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

#import "CanvasView.h"
#import "Canvas.h"


@implementation CanvasView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}

- (void)awakeFromNib
{
    _canvas = [[Canvas alloc] init];
}

- (void)drawRect:(CGRect)dirtyRect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [_canvas drawRect:dirtyRect inContext:context];
}

@end
