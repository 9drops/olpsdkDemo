//
//  OLPBluetoothManager.m
//  OLP-SDK
//
//  Created by drops on 2025/2/28.
//

#import "OLPBluetoothManager.h"
#import <olpsdk/OLPBluetoothHelper.h>

@implementation OLPBluetoothManager {
    CBCentralManager *centralManager;
    CBPeripheral *connectedPeripheral;
}

+ (instancetype)shared {
    static OLPBluetoothManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.bluetoothHelper = [OLPBluetoothHelper shared]; //初始化实例初
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

///重连蓝牙设备
- (void)reconnect {
    if (centralManager.state == CBManagerStatePoweredOn && connectedPeripheral.state == CBPeripheralStateDisconnected) {
        [centralManager connectPeripheral:connectedPeripheral options:nil];
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBManagerStatePoweredOn) {
        if (self.targetUUID) {
            NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:self.targetUUID];
            NSArray *peripherals = [central retrievePeripheralsWithIdentifiers:@[uuid]];
            if (peripherals.count > 0) {
                [central connectPeripheral:peripherals.firstObject options:nil];
            }
        } else {
            [centralManager scanForPeripheralsWithServices:nil options:nil];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if ([self.targetUUID isEqualToString:peripheral.identifier.UUIDString] || (self.peripheralNamePrefix && [peripheral.name hasPrefix:self.peripheralNamePrefix])) {
        [central stopScan];
        [central connectPeripheral:peripheral options:nil];
        connectedPeripheral = peripheral; //持久化peripheral对象，避免释放
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    connectedPeripheral = peripheral;
    self.bluetoothHelper.connectedPeripheral = peripheral; //设置已连接设备
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    
    NSString *uuidString = peripheral.identifier.UUIDString;
    self.targetUUID = uuidString;
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"蓝牙设备断开，尝试重新连接...");
    [central connectPeripheral:peripheral options:nil];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"Failed to discover services: %@", error.localizedDescription);
        return;
    }

    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Failed to discover characteristics: %@", error.localizedDescription);
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        self.bluetoothHelper.addDiscoveredCharacteristicBlock(characteristic); //注册特征
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    self.bluetoothHelper.didWriteValueForCharacteristicBlock(peripheral, characteristic, error); //回调写完成block
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    self.bluetoothHelper.didUpdateValueForCharacteristicBlock(peripheral, characteristic, error); //回调值更新block
}

#pragma mark - getters

//耳机设备名称，如果用户没有设置，默认返回"OLEAP Archer"
- (NSString *)peripheralNamePrefix {
    if (!_peripheralNamePrefix) {
        _peripheralNamePrefix = @"OLEAP Archer";
    }
    
    return _peripheralNamePrefix;
}

@end
