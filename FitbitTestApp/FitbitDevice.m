//
//  FitbitDevice.m
//  FitBitTestApp
//
//  Created by Christopher Wade on 6/7/13.
//  Copyright (c) 2013 cmw. All rights reserved.
//

#import "FitbitDevice.h"
#import "PacketHandler.h"

#include <stdint.h>

#define CRC16 0x8005
uint16_t gen_crc16(const uint8_t *data, uint16_t size);
uint16_t gen_crc16(const uint8_t *data, uint16_t size)
{
    uint16_t out = 0;
    int bits_read = 0, bit_flag;
    
    /* Sanity check: */
    if(data == NULL)
        return 0;
    
    while(size > 0)
    {
        bit_flag = out >> 15;
        
        /* Get next bit: */
        out <<= 1;
        out |= (*data >> (7 - bits_read)) & 1;
        
        /* Increment bit counter: */
        bits_read++;
        if(bits_read > 7)
        {
            bits_read = 0;
            data++;
            size--;
        }
        
        /* Cycle check: */
        if(bit_flag)
            out ^= CRC16;
        
    }
    return out;
}
@interface NSData (FBBlue)
- (unsigned short)crc16Checksum;
- (BOOL)verificationStringForBlockWithLength:(unsigned long)length andCRC:(unsigned short)crc16;
@end

@implementation NSData (FBBlue)
- (unsigned short)crc16Checksum
{
    const uint8_t *bytes = (const uint8_t *)[self bytes];
    uint16_t length = (uint16_t)[self length];
    return (unsigned short)gen_crc16(bytes, length);
}
- (BOOL)verificationStringForBlockWithLength:(unsigned long)length andCRC:(unsigned short)crc16
{
    NSLog(@"verificationStringForBlockWithLength : %lu and crc: %d and received data %lu and crc: %d", length, crc16, (unsigned long)[self length], [self crc16Checksum]);
    //if([self crc16Checksum] == crc16 && length == [self length])
    if(length == [self length])

        return 1;
    else
        return 0;
}
@end
@implementation FitbitDevice

@synthesize authenticating=_authenticating;
@synthesize btManager;
@synthesize batteryLevel;
@synthesize airlinkVersionMajor=_airlinkVersionMajor;
@synthesize airlinkVersionMinor=_airlinkVersionMinor;
@synthesize connecting=_connecting;
@synthesize isLinked=_isLinked;
@synthesize hasDataServiceUUIDString=_hasDataServiceUUIDString;
@synthesize MACAddressString=_MACAddressString;
@synthesize authenticated=_authenticated;
@synthesize trackerAuth=_trackerAuth;
@synthesize fitbitActivityCharacteristic=_fitbitActivityCharacteristic;
@synthesize fitbitActivityCharacteristicUUID=_fitbitActivityCharacteristicUUID;
@synthesize operation=_operation;
@synthesize receivedData=_receivedData;


static FitbitDevice *_singleton;

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedInstance];
}

+ (FitbitDevice *)sharedInstance {
    
    @synchronized (self) {
        if (!_singleton)
        {
            _singleton = [[super allocWithZone:NULL] init];
        }
    }
    return _singleton;
}

- (void)initDevice
{
    btManager = [[BTPeripheral alloc] init];
    [btManager controlSetup:1];
    btManager.delegate = self;
    receiveCharacteristicUUID = [CBUUID UUIDWithString:@"ADABFB02-6E7D-4601-BDA2-BFFAA68956BA"];
    transmitCharacteristicUUID = [CBUUID UUIDWithString:@"ADABFB01-6E7D-4601-BDA2-BFFAA68956BA"];
}
//  C0 0A 01 00 08 00 10 00   00 00 C8 00 01

- (void)startAirLink
{
    unsigned char bytes[13] = {0};
    
    bytes[0] = 0xC0;
    bytes[1] = 0x0A;
    bytes[2] = 0x1;
    bytes[4] = 0x08; /* 08 for iOS6? 0x10 for iOS 5? */
    bytes[6] = 0x10;
    bytes[10] = 0xc8;
    bytes[12] = 0x01;
    
    NSData *packet = [NSData dataWithBytes:bytes length:13];

    if([self btManager].mainService)
    {
        [[self btManager] writeValue:[self btManager].mainService c:receiveCharacteristicUUID p:[[self btManager] activePeripheral] data:packet];
    } else {
        NSLog(@"Unable to find service");
    }
}

- (void)handleAirlinkInit:(NSData *) data
{
    unsigned char *bytes;
    if([data length] >= 6)
    {
        bytes = (unsigned char *)[data bytes];
        [self setAirlinkVersionMajor:bytes[3]];
        [self setAirlinkVersionMinor:bytes[4]];
        [self setIsLinked:1];
        [self setConnecting:0];
        NSLog(@"AirlinkVersionMajor:%d", [self airlinkVersionMajor]);
        NSLog(@"AirlinkVersionMinor:%d", [self airlinkVersionMinor]);
        if ( (bytes[2] & 0xF) == 12 && [data length] >= 0xC )
        {
            [self setHasDataServiceUUIDString:[NSString stringWithFormat:@"ADAB%.2X%.2X-6E7D-4601-BDA2-BFFAA68956BA", (unsigned char)((bytes[10] ^ bytes[6] ^ bytes[8]) & 0x7f), (unsigned char)(bytes[7] ^ bytes[9] ^ bytes[11])]];
            [self setMACAddressString:[NSString stringWithFormat:@"%.2X%.2X%.2X%.2X%.2X%.2X", bytes[6], bytes[7], bytes[8], bytes[9], bytes[10], bytes[11]]];
            NSLog(@"DataServiceUUIDString: %@", [self hasDataServiceUUIDString]);
            NSLog(@"MACAddressString: %@", [self MACAddressString]);
            [self startOperation];
        }
    }
}

-(void) startOperation
{
    
    if(![self authenticated])
    {
        // Lets auth
        [self startAuth];
    }
}

- (void) startAuth
{
    [self setAuthenticating:1];
    if(![self trackerAuth])
    {
        [self setTrackerAuth:[[FBTrackerAuth alloc] init]];
    }
    if([[self trackerAuth] loadKey])
    {
        [self continueAuth];
    } else {
        [self triggerMicroDump];
    }
}

- (void)triggerMicroDump
{
    NSLog(@"triggerMicroDump");
    unsigned char bytes[3] = {0};
    
    
    bytes[0] = 0xC0;
    bytes[1] = 0x10;
    bytes[2] = 0x3;
    
    NSData *packet = [NSData dataWithBytes:bytes length:3];
    
    if([self btManager].mainService)
    {
        [[self btManager] writeValue:[self btManager].mainService c:receiveCharacteristicUUID p:[[self btManager] activePeripheral] data:packet];
    } else {
        NSLog(@"Unable to find service");
    }
}

-(void)handleNak:(NSData *)data
{
    if([self authenticating])
    {
        NSLog(@"Auth failed!!!");
        [self setAuthenticating:0];
    } else {
        NSLog(@"Seems something failed");
    }
}

-(void)triggerMegaDump
{
    NSLog(@"triggerMegaDump");
    unsigned char bytes[3] = {0};
    
    
    bytes[0] = 0xC0;
    bytes[1] = 0x10;
    bytes[2] = 0xD;
    
    NSData *packet = [NSData dataWithBytes:bytes length:3];
    
    if([self btManager].mainService)
    {
        [[self btManager] writeValue:[self btManager].mainService c:receiveCharacteristicUUID p:[[self btManager] activePeripheral] data:packet];
    } else {
        NSLog(@"Unable to find service");
    }
}

- (void)continueAuth
{
    unsigned char bytes[10] = {0};
    
    
    bytes[0] = 0xC0;
    bytes[1] = 0x50;
    bytes[2] = [[self trackerAuth] random];
    bytes[6] = [[self trackerAuth] nonce];
    
    NSData *packet = [NSData dataWithBytes:bytes length:10];
    
    if([self btManager].mainService)
    {
        [[self btManager] writeValue:[self btManager].mainService c:receiveCharacteristicUUID p:[[self btManager] activePeripheral] data:packet];
    } else {
        NSLog(@"Unable to find service");
    }
}

- (void)appendRecvData:(NSData *)data
{
    NSLog(@"Handle data!");
    if(!receivedData)
    {
        receivedData = [[NSMutableData alloc] init];
    }
    [receivedData appendData:data];
}

- (void)handleStreamStarting:(NSData *)data
{
    if([data length] >= 3)
    {
        NSLog(@"Clearing recv data");
        receivedData = nil;
    }
}

- (void)handleStreamFinished:(NSData *)data
{
    unsigned char *bytes = (unsigned char *)[data bytes];
    unsigned int length = bytes[5];
    if([data length] >= 9)
    {
        [receivedData verificationStringForBlockWithLength:length andCRC:0];
    }
    NSLog(@"Received data: %@", [receivedData hexdump]);
}

- (void)handleClientAuthChallenge:(NSData *)data
{
    unsigned char *bytes;
    if([data length] >= 0xE)
    {
        bytes = (unsigned char *)[data bytes];
        [self sendClientAuthResponse:(unsigned char *)[data bytes]];
    }
}

- (void) sendClientAuthResponse: (unsigned char *) data
{
    unsigned char bytes[10] = {0};
    
    
    bytes[0] = 0xC0;
    bytes[1] = 0x52;

    for(int i=0; i < 5;i++)
    {
        bytes[5+i] = data+i;
    }
    
    NSData *packet = [NSData dataWithBytes:bytes length:10];
    
    if([self btManager].mainService)
    {
        [[self btManager] writeValue:[self btManager].mainService c:receiveCharacteristicUUID p:[[self btManager] activePeripheral] data:packet];
    } else {
        NSLog(@"Unable to find service");
    }
}

- (void)handleAck:(NSData *) data
{
    if([self authenticating])
    {
        NSLog(@"Authenticated!!!!");
        [self setAuthenticating:0];
        [self setAuthenticated:1];
        [self displayCode];
        if([self fitbitActivityCharacteristic])
        {
            // should register for fitbitactivitychar here
            // setNotifyValue:forCharacteristic:
        }
    } else {
        if([self operation])
        {
            [[self operation] requestFinishedSuccess:1];
        }
    }
}

- (void) connected
{
    [self startAirLink];

}

- (void) displayCode
{
    unsigned char bytes[2] = {0};
    
    
    bytes[0] = 0xC0;
    bytes[1] = 0x6;
    
    NSData *packet = [NSData dataWithBytes:bytes length:2];

    if([self btManager].mainService)
    {
        [[self btManager] writeValue:[self btManager].mainService c:receiveCharacteristicUUID p:[[self btManager] activePeripheral] data:packet];
    } else {
        NSLog(@"Unable to find service");
    }
}

- (void)didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    UInt16 characteristicUUID = [[self btManager] CBUUIDToInt:characteristic.UUID];
    NSLog(@"recv[%x] %d bytes [%@]: %@", characteristicUUID, [[characteristic value] length], [[characteristic UUID] description], [[characteristic value] hexdump]);
    if (!error) {
        switch(characteristicUUID){
            case 0x2a19:
            {
                char batlevel;
                [characteristic.value getBytes:&batlevel length:1];
                NSLog(@"Battery level %x", batlevel);
                self.batteryLevel = (float)batlevel;
                return;
            }
        }
    }
    [PacketHandler handlePacket:[characteristic value] withCallBack:self];
}
@end
