//
//  OLPBluetoothHelper.h
//  OLP-SDK
//
//  Created by drops on 2025/3/2.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "OLPModel.h"

NS_ASSUME_NONNULL_BEGIN

//错误码
typedef NS_ENUM(NSInteger, OLPErrCode) {
    OLPErrCodeOK = 0, //成功
    OLPErrCodeCmdTimeout = 999, //名字执行超时
    OLPErrCodeDisconnected, //蓝牙断开
    OLPErrCodeCharacterNotFound, //找不到特征值
    OLPErrCodeWaiting, //已有操作进行中
    OLPErrCodeRecordType, //录音类型错误
    OLPErrCodeRecordInner, //录音错误
    OLPErrCodeGetFileId, //文件ID获取失败
    OLPErrCodeGetFileInfo, //获取文件信息失败
    OLPErrCodeDownloaded, //已下载文件长度大于待下载文件总长度
    OLPErrCodeUpdateFirmwarePrepare, //固件更新-准备失败
    OLPErrCodeUpdateFirmwareConfig, //固件更新-配置失败
    OLPErrCodeUpdateSelectionSide, //分区选择错误
    OLPErrCodeFirmwareNil, //固件更新失败-空数据
    OLPErrCodeUpdateCheck, //固件更新-校验错误
    OLPErrCodeUpdateBye, //固件更新-结束失败
};

@interface OLPBluetoothHelper : NSObject

//已连接的蓝牙设备
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;
//发现蓝牙设备回调
@property (nonatomic, strong) OLPDidDiscoverPeripheralBlock didDiscoverPeripheralBlock;
//蓝牙设备连接成功或出错回调
@property (nonatomic, strong) OLPDidConnectPeripheralBlock didConnectPeripheralBlock;

@property (nonatomic, strong, readonly) OLPAddDiscoveredCharacteristicBlock addDiscoveredCharacteristicBlock;
@property (nonatomic, strong, readonly) OLPDidWriteValueForCharacteristicBlock didWriteValueForCharacteristicBlock;
@property (nonatomic, strong, readonly) OLPDidUpdateValueForCharacteristicBlock didUpdateValueForCharacteristicBlock;

+ (instancetype)shared;

/// 蓝牙设备连接状态
- (CBPeripheralState)peripheralConnectState;

/// 获取剩余电量（百分比的数值部分）
/// result：失败，error非nil 成功，error为nil
- (void)getPower:(void(^)(NSError *error, NSInteger power))result;

/// 获取固件版本号
/// - Parameters:
///   - result: 返回结果回调block
- (void)getFirmwareVersion:(void (^)(NSError *error, NSString *version))result;

/// 固件更新
/// - Parameters:
///   - filePath: 固件文件路径
///   - progress: 固件文件上传进度
///   - completion: 成功：error为nil，其他失败
- (void)updateFirmware:(NSString *)filePath progress:(OLPProgress)progress completion:(OLPCallBack)completion;

/// 获取Flash文件信息列表
/// - Parameter completion: 文件信息列表
- (void)getFlashFileList:(void (^)(NSError *error, NSArray<OLPFileHeader *> *fileList))completion;

/// 获取耳机存储容量（总字节数、剩余字节数）
/// - Parameters:
///   - completion: 成功：error为nil，其他失败, flashCapacity:[总容量, 剩余容量]
- (void)getCapacity:(void (^)(NSError *error, NSArray<NSNumber *> *flashCapacity))completion;

/// 从蓝牙耳机下载启始文件到APP，下载成功后从耳机删除此文件
/// - Parameters:
///   - outputFilePath: 下载后保存的文件路径
///   - progress 下载进度
///   - completion: 成功：error为nil，其他失败
- (void)downloadFirstFlashFile:(NSString *)outputFilePath progress:(OLPProgress)progress completion:(void (^)(NSError *error))completion;

/// 从蓝牙耳机删除启始文件
/// - Parameters:
/// - completion: 成功：error为nil，其他失败
- (void)deleteFirstFlashFile:(void (^)(NSError *error))completion;

/// 启动录音
/// - Parameters:
///   - recordType: 录音类型
///   - outputFilePath: 录音文件保存路径
///   - completion: 成功：error为nil，其他失败
- (void)startRecordWithType:(OLPRecordType)recordType toOutputFilePath:(NSString *)outputFilePath completion:(void (^)(NSError *error))completion;

/// 停止录音
/// - Parameters:
/// - completion: 录音结果
- (void)stopRecord:(void (^)(NSError *error))completion;

/// opus文件转码
/// - Parameters:
///   - inputPath: 待转码的opus文件路径
///   - outputFilePath: 转码后的文件路径
///   - decodeType：目标文件类型
///  - Return YES:转码成功 NO:转码失败
- (BOOL)decodeOpusFile:(NSString *)inputPath toOutputFilePath:(NSString *)outputFilePath withDecodeType:(OLPDecodeType)decodeType;

@end

NS_ASSUME_NONNULL_END
