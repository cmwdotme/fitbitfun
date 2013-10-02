//
//  FitbitDevice.h
//  FitBitTestApp
//
//  Created by Christopher Wade on 6/7/13.
//  Copyright (c) 2013 cmw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTPeripheral.h"
#import "FBTrackerAuth.h"

@protocol FBOperating <NSObject>
- (void)requestFinishedSuccess:(BOOL)arg1;
- (void)handleData:(id)arg1;
- (void)startWithPeripheral:(id)arg1;
@end

@interface FitbitDevice : NSObject <BTPeripheralDelegate>
{
    CBUUID *receiveCharacteristicUUID;
    CBUUID *transmitCharacteristicUUID;
    CBCharacteristic *receiveCharacteristic;
    CBCharacteristic *transmitCharacteristic;
    int _airlinkVersionMinor;
    int _airlinkVersionMajor;
    BOOL _isLinked;
    BOOL _connecting;
    NSString *_hasDataServiceUUIDString;
    NSString *MACAddressString;
    BOOL _authenticated;
    FBTrackerAuth *_trackerAuth;
    BOOL authenticating;
    CBUUID *_fitbitActivityCharacteristicUUID;
    CBCharacteristic *_fitbitActivityCharacteristic;
    NSObject<FBOperating> *_operation;
    NSMutableData * receivedData;

}
@property(retain, nonatomic) NSMutableData * receivedData;
@property(retain, nonatomic) NSObject<FBOperating> *operation;
@property(retain, nonatomic) CBUUID *fitbitActivityCharacteristicUUID; 
@property(retain, nonatomic) CBCharacteristic *fitbitActivityCharacteristic;
@property(nonatomic) BOOL authenticating; 
@property(retain) FBTrackerAuth *trackerAuth;
@property(nonatomic) int airlinkVersionMinor;
@property(nonatomic) int airlinkVersionMajor;
@property(nonatomic) BOOL connecting; // @synthesize connecting=_connecting;
@property(nonatomic) BOOL isLinked; // @synthesize isLinked=_isLinked;
@property(retain, nonatomic) NSString *hasDataServiceUUIDString; // @synthesize hasDataServiceUUIDString=_hasDataServiceUUIDString;
@property(retain, nonatomic) NSString *MACAddressString; // @synthesize MACAddressString=_MACAddressString;
@property(nonatomic) BOOL authenticated;


@property (nonatomic)   float batteryLevel;
@property (strong, nonatomic)  BTPeripheral *btManager;

-(void)triggerMegaDump;
-(void)handleNak:(NSData *)data;
+ (FitbitDevice *)sharedInstance;
- (void)startAirLink;
- (void) displayCode;
- (void)initDevice;
- (void)triggerMicroDump;
- (void)didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
@end
