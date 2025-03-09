//
//  OLPModel.h
//  OLP-SDK
//
//  Created by drops on 2025/3/10.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^OLPAddDiscoveredCharacteristicBlock)(CBCharacteristic *characteristic);
typedef void (^OLPDidWriteValueForCharacteristicBlock)(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error);
typedef void (^OLPDidUpdateValueForCharacteristicBlock)(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error);

typedef void (^OLPProgress)(NSUInteger totalSent, NSUInteger expectedSend);
typedef void (^OLPCallBack)(NSError * _Nullable error, id _Nullable result);


//固件更新错误类型
typedef NS_ENUM(NSInteger, OLPUpdateFirmwareError) {
    OLPUpdateFirmwareErrorReadFile  = -1, //读文件错误
    OLPUpdateFirmwareErrorDataNil   = -2, //空数据
    OLPUpdateFirmwareErrorSend      = -3, //发送错误
    OLPUpdateFirmwareErrorDataCheck = -4, //校验失败
};

// 解码类型
typedef NS_ENUM(NSInteger, OLPDecodeType) {
    OLPDecodeTypeMP3 = 0, //opus convert to mp3
    OLPDecodeTypeWAV, //opus convert to wav
};

// 录音类型
typedef NS_ENUM(NSInteger, OLPRecordType) {
    OLPRecordTypePersonal, //降噪
    OLPRecordTypeCall, //通话
    OLPRecordTypeAudio,//媒体
    OLPRecordTypeAmbient, //环境
    OLPRecordTypeStop, //结束录音
};

@interface OLPFileTime : NSObject

@property (nonatomic, assign) uint8_t year;
@property (nonatomic, assign) uint8_t month;
@property (nonatomic, assign) uint8_t day;
@property (nonatomic, assign) uint8_t hour;
@property (nonatomic, assign) uint8_t minute;
@property (nonatomic, assign) uint8_t second;

+ (instancetype)fileTimeWithYear:(uint8_t)year month:(uint8_t)month day:(uint8_t)day hour:(uint8_t)hour minute:(uint8_t)minute second:(uint8_t)second;
+ (instancetype)fileTimeStruct:(void *)fileTime;

@end

@interface OLPFileHeader : NSObject

@property (nonatomic, assign) BOOL exist;
@property (nonatomic, assign) OLPFileTime *creatTime;
@property (nonatomic, assign) OLPRecordType recordType;
@property (nonatomic, assign) NSUInteger filesize;

+ (instancetype)headerWithCreatTime:(OLPFileTime *)creatTime recordType:(OLPRecordType)recordType filesize:(uint64_t)filesize exist:(BOOL)exist;

@end

NS_ASSUME_NONNULL_END
