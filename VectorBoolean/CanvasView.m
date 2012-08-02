//
//  CanvasView.m
//  VectorBoolean
//
//  Created by Andrew Finnell on 5/31/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

#import "CanvasView.h"
#import "Canvas.h"


@implementation CanvasView

@synthesize canvas=_canvas;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _canvas = [[Canvas alloc] init];
    }
    
    return self;
}

- (void)drawRect:(CGRect)dirtyRect
{
    [_canvas drawRect:dirtyRect];
}

@end
