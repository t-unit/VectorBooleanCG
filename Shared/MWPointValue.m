//
//  MWPointValue.m
//  VectorBoolean
//
//  Created by Martin Winter on 02.08.12.
//  Copyright (c) Martin Winter. All rights reserved.
//

#import "MWPointValue.h"


@implementation MWPointValue
{
    NSNumber *_xNumber;
    NSNumber *_yNumber;
}


- (instancetype)initWithPoint:(MWPoint)point
{
    self = [super init];
    if (self)
    {
        _xNumber = @(point.x);
        _yNumber = @(point.y);
    }
    return self;
}


- (instancetype)init
{
    return [self initWithPoint:MWPointZeroMake()];
}


- (NSString *)description
{
    MWPoint point = [self point];
    return [NSString stringWithFormat:@"<%@ %#llx {%f, %f}>",
            NSStringFromClass([self class]), (u_int64_t)self, point.x, point.y];
}


- (MWPoint)point
{
    return MWPointMake([_xNumber doubleValue], [_yNumber doubleValue]);
}


@end
