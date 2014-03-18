//
//  CanvasView.h
//  VectorBoolean
//
//  Created by Andrew Finnell on 5/31/11.
//  Adapted for cross-platform use by Martin Winter on 2012-08-03.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//


@class Canvas;

// This is the view for use on iOS.
@interface CanvasView : UIView

@property (readonly) Canvas *canvas;

@end
