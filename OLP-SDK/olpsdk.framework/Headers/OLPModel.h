//
//  OLPModel.h
//  OLP-SDK
//
//  Created by drops on 2025/3/10.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^OLPDidDiscoverPeripheralBlock)(CBPeripheral *peripheral);
typedef void (^OLPDidConnectPeripheralBlock)(CBPeripheral * _Nullable peripheral, NSError * _Nullable error);
typedef void (^OLPAddDiscoveredCharacteristicBlock)(CBCharacteristic *characteristic);
typedef void (^OLPDidWriteValueForCharacteristicBlock)(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error);
typedef void (^OLPDidUpdateValueForCharacteristicBlock)(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error);

typedef void (^OLPProgress)(NSUInteger totalSent, NSUInteger expectedSend);
typedef void (^OLPCallBack)(NSError * _Nullable error, id _Nullable result);


// 解码类型
typedef NS_ENUM(NSInteger, OLPDecodeType) {
    OLPDecodeTypeMP3 = 0, //opus convert to mp3
    OLPDecodeTypeWAV, //opus convert to wav
};

// 录音类型
typedef NS_ENUM(NSInteger, OLPRecordType) {
    OLPRecordTypeANC, //降噪
    OLPRecordTypeCall, //通话
    OLPRecordTypeMedia,//媒体
    OLPRecordTypeAmbient, //环境
    OLPRecordTypeStop, //结束录音
};

#define OLP_RECORD_DESCS @{@(OLPRecordTypeANC) : @"降噪", @(OLPRecordTypeCall) : @"通话", @(OLPRecordTypeMedia) : @"媒体"}

@interface OLPFileTime : NSObject

@property (nonatomic, assign) uint8_t year;
@property (nonatomic, assign) uint8_t month;
@property (nonatomic, assign) uint8_t day;
@property (nonatomic, assign) uint8_t hour;
@property (nonatomic, assign) uint8_t minute;
@property (nonatomic, assign) uint8_t second;

+ (instancetype)fileTimeWithYear:(uint8_t)year month:(uint8_t)month day:(uint8_t)day hour:(uint8_t)hour minute:(uint8_t)minute second:(uint8_t)second;
+ (instancetype)fileTimeStruct:(void *)fileTime;
- (NSDate *)toDate;

@end

@interface OLPFileHeader : NSObject

@property (nonatomic, assign) BOOL exist;
@property (nonatomic, assign) NSDate *creatTime;
@property (nonatomic, assign) OLPRecordType recordType;
@property (nonatomic, assign) NSUInteger filesize;

+ (instancetype)headerWithCreatTime:(OLPFileTime *)creatTime recordType:(OLPRecordType)recordType filesize:(uint64_t)filesize exist:(BOOL)exist;

@end

NS_ASSUME_NONNULL_END
