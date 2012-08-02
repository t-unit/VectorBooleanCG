//
//  CanvasView.h
//  VectorBoolean
//
//  Created by Andrew Finnell on 5/31/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//

@class Canvas;

#if TARGET_OS_IPHONE
#define MWKC_MAIN_VIEW_CLASS UIView
#else
#define MWKC_MAIN_VIEW_CLASS NSView
#endif

@interface CanvasView : MWKC_MAIN_VIEW_CLASS {
    Canvas *_canvas;    
}

@property (readonly) Canvas *canvas;

@end
