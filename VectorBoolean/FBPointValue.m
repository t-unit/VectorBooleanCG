//
//  FBPointValue.m
//  VectorBoolean
//
//  Created by Martin Winter on 02.08.12.
//  Copyright (c) 2012 Fortunate Bear, LLC. All rights reserved.
//

#import "FBPointValue.h"


@implementation FBPointValue
{
    NSDictionary *_dictionary;
}


- (id)initWithPoint:(CGPoint)point
{
    self = [super init];
    if (self)
    {
        _dictionary = (NSDictionary *)CFBridgingRelease(CGPointCreateDictionaryRepresentation(point));
    }
    return self;
}


- (id)init
{
    return [self initWithPoint:CGPointZero];
}


- (CGPoint)point
{
    CGPoint point;
    bool success = CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(_dictionary), &point);
    return (success) ? point : CGPointZero;
}


@end
