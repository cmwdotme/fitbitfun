//
//  PacketHandler.m
//  FitBitTestApp
//
//  Created by Christopher Wade on 6/7/13.
//  Copyright (c) 2013 cmw. All rights reserved.
//

#import "PacketHandler.h"

@implementation PacketHandler

+ (void)handlePacket:(NSData *) packet withCallBack:(id)callback
{
    unsigned int v11;
    unsigned int v13;
    unsigned int v14;
    
    if([packet length] > 0)
    {
        unsigned char *bytes = (unsigned char *)[packet bytes];
        if(bytes[0] == 0xC0)
        {
            
            if ([packet length] >= 2 )
            {
                unsigned int v5 = (bytes[1] >> 4) & 7;
                if ( (unsigned int)v5 <= 5 )
                {
                    switch ( v5 )
                    {
                        case 0:
                            v11 = (bytes[1] & 0xF) - 1;
                            if (v11 <= 7 )
                            {
                                switch ( v11 )
                                {
                                    case 0:
                                        NSLog(@"Handle airlink reset");
                                        break;
                                    case 1:
                                        [callback performSelector:@selector(handleAck:) withObject:packet];
                                        break;
                                    case 2:
                                        [callback performSelector:@selector(handleNak:) withObject:packet];
                                        return;
                                    case 7:
                                        //[callback performSelector:@selector(decodeUserActivity:) withObject:packet];
                                        break;
                                    default:
                                        NSLog(@"error? ");
                                        return;
                                }
                                return;
                            }
                            break;
                        case 1:
                            v13 = bytes[1] & 0xF;
                            if ( v13 == 2 )
                            {
                                [callback performSelector:@selector(handleFirstBlock:) withObject:packet];
                                return;
                            }
                            if ( v13 == 3 )
                            {
                                [callback performSelector:@selector(handleNextBlock:) withObject:packet];
                                return;
                            }
                            if ( v13 == 4 )
                            {
                                [callback performSelector:@selector(handleAirlinkInit:) withObject:packet];
                                return;
                            }
                            break;
                        case 4:
                            v14 = bytes[1] & 0xF;
                            if ( v14 == 2 )
                            {
                                [callback performSelector:@selector(handleStreamFinished:) withObject:packet];
                                return;
                            }
                            if ( v14 == 1 )
                            {
                                [callback performSelector:@selector(handleStreamStarting:) withObject:packet];
                                return;
                            }
                            break;
                        case 5:
                            if ( (bytes[1] & 0xF) == 1 )
                            {
                                [callback performSelector:@selector(handleClientAuthChallenge:) withObject:packet];
                                return;
                            }
                            break;
                    }
                }
            }
        }
        else
        {
            [callback performSelector:@selector(appendRecvData:) withObject:packet];
        }
    }
    
}

+ (NSData *) HandleData:(NSData *)data
{
    unsigned char val;
    NSMutableData *newData = nil;
    unsigned char *bytes = (unsigned char *)[data bytes];
    
    if([data length] > 0x14 || bytes[0] == 0xC0)
    {
        return [NSMutableData dataWithCapacity:0];
    }
    if([data length] <= 1 || bytes[0] != 0xDB)
        return [data copy];
    
    newData = [NSMutableData dataWithCapacity:[data length]];
    if ( bytes[1] == 0xDD )
    {
        val = 0xDB;
        [newData appendBytes:&val length:1];
        if ([data length] >= 3 )
        {
            [newData appendBytes:(char *)bytes+3 length:[data length] - 2];
        }
        return newData;
    }
    if (bytes[1] != 0xDC )
    {
        return [data copy];
    }
    val = 0xC0;
    [newData appendBytes:&val length:1];
    if ([data length] >= 3 )
    {
        [newData appendBytes:(char *)bytes+2 length:[data length] - 2];
    }
    return newData;
}

@end
