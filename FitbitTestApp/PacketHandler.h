//
//  PacketHandler.h
//  FitBitTestApp
//
//  Created by Christopher Wade on 6/7/13.
//  Copyright (c) 2013 cmw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PacketHandler : NSObject

+ (void)handlePacket:(NSData *) packet withCallBack:(id)callback;
+ (NSData *) HandleData:(NSData *)data;
@end
