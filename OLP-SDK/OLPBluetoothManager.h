//
//  OLPBluetoothManager.h
//  OLP-SDK
//
//  Created by drops on 2025/2/28.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class OLPBluetoothHelper;

@interface OLPBluetoothManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) OLPBluetoothHelper *bluetoothHelper;
@property (nonatomic, strong) NSString *peripheralNamePrefix; //耳机设备名称，"OLEAP Archer"
@property (nonatomic, strong) NSString *targetUUID; //耳机的UUID

+ (instancetype)shared;

@end
