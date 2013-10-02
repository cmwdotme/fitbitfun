//
//  FBTrackerAuth.m
//  FitBitTestApp
//
//  Created by Christopher Wade on 6/7/13.
//  Copyright (c) 2013 cmw. All rights reserved.
//

#import "FBTrackerAuth.h"

@implementation FBTrackerAuth

- (BOOL) loadKey
{
    NSMutableData *key = [NSMutableData dataWithCapacity:16];
    [self setKey:key];
    [self setNonce:0];
    return 1;
}

- (int)generateRandom
{
    [self setRandom:0];
    return 0;
}
@end
