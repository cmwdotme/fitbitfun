//
//  BTPeripheral.h
//  FitBitTestApp
//
//  Created by Christopher Wade on 6/7/13.
//  Copyright (c) 2013 cmw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>


@protocol BTPeripheralDelegate
@optional
-(void) connected;
- (void)didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
@end

@interface BTPeripheral :  NSObject <CBCentralManagerDelegate, CBPeripheralDelegate> {
}


@property (nonatomic,assign) id <BTPeripheralDelegate> delegate;
@property (strong, nonatomic)  NSMutableArray *peripherals;
@property (strong, nonatomic) CBCentralManager *cbManager;
@property (strong, nonatomic) CBPeripheral *activePeripheral;
@property (strong, nonatomic) CBService *mainService;

- (NSMutableArray *) getKnownPeripherals;
- (void) connectPeripheralWithString:(NSString *) val;
- (int) findPeripherals:(int) timeout;
- (void) connectPeripheral:(CBPeripheral *)peripheral;
- (int) controlSetup: (int) s;
-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p;
-(void) writeValue:(CBService *)service c:(CBUUID *)c p:(CBPeripheral *)p data:(NSData *)data;
-(UInt16) CBUUIDToInt:(CBUUID *) UUID;
@end
