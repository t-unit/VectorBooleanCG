//
//  MWPointValue.h
//  VectorBoolean
//
//  Created by Martin Winter on 02.08.12.
//  Copyright (c) 2012 Martin Winter. All rights reserved.
//

#import "MWGeometry.h"

@interface MWPointValue : NSObject

- (instancetype)initWithPoint:(MWPoint)point NS_DESIGNATED_INITIALIZER;
@property (readonly) MWPoint point;

@end
