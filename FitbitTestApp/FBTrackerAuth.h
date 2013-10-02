//
//  FBTrackerAuth.h
//  FitBitTestApp
//
//  Created by Christopher Wade on 6/7/13.
//  Copyright (c) 2013 cmw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBTrackerAuth : NSObject
{
    NSData *_key;
    unsigned int _random;
    unsigned int _nonce;
    id _completion;
}

@property(copy, nonatomic) id completion; // @synthesize completion=_completion;
@property(nonatomic) unsigned int nonce; // @synthesize nonce=_nonce;
@property(nonatomic) unsigned int random; // @synthesize random=_random;
@property(copy, nonatomic) NSData *key; // @synthesize key=_key;
- (BOOL)loadKey;
@end