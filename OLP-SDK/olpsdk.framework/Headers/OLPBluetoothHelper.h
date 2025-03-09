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

@interface OLPBluetoothHelper : NSObject

@property (nonatomic, strong) CBPeripheral *connectedPeripheral;
@property (nonatomic, strong, readonly) OLPAddDiscoveredCharacteristicBlock addDiscoveredCharacteristicBlock;
@property (nonatomic, strong, readonly) OLPDidWriteValueForCharacteristicBlock didWriteValueForCharacteristicBlock;
@property (nonatomic, strong, readonly) OLPDidUpdateValueForCharacteristicBlock didUpdateValueForCharacteristicBlock;

+ (instancetype)shared;

/// 获取剩余电量（百分比）
- (void)getPower:(void(^)(NSError *error, NSInteger power))result;

/// 获取固件版本号
/// - Parameters:
///   - result: 返回结果回调block
- (void)getFirmwareVersion:(void (^)(NSError *error, NSString *version))result;

/// ⚠️TODO：此接口暂不可用，待解决问题：执行开始指令后发送数据包蓝牙就断开
/// - Parameters:
///   - filePath: 固件文件路径
///   - progress: 固件文件上传进度
///   - completion: 成功：error为nil，其他失败
- (void)updateFirmware:(NSString *)filePath progress:(OLPProgress)progress completion:(OLPCallBack)completion;


/// 获取Flash中文件数和起始文件ID
/// - Parameter completion: {@"Num": 文件数, @"FirstId": 起始文件ID}
- (void)getFileNumAndFirstId:(void (^)(NSError *error, NSDictionary<NSString *, NSNumber *> *))completion;


/// 由文件ID获取文件信息
/// - Parameters:
///   - fileId: 文件ID
///   - completion: 文件信息OLPFileHeader对象
- (void)getFileInfo:(NSInteger)fileId completion:(void (^)(NSError * _Nullable , OLPFileHeader * _Nullable))completion;


/// 获取Flash文件信息列表
/// - Parameter completion: 文件信息列表
- (void)getFlashFileList:(void (^)(NSError *error, NSArray<OLPFileHeader *> *fileList))completion;

/// 获取耳机存储容量（总字节数、剩余字节数）
/// - Parameters:
///   - completion: 成功：error为nil，其他失败, flashCapacity:@{"Total":, @"Free"}
- (void)getCapacity:(void (^)(NSError *error, NSDictionary<NSString *, NSNumber *> *flashCapacity))completion;

/// 从蓝牙耳机下载启始文件到APP，下载成功后从耳机删除此文件
/// - Parameters:
///   - outputFilePath: 下载后保存的文件路径
///   - completion: 成功：error为nil，其他失败
- (void)downloadFirstFlashFile:(NSString *)outputFilePath completion:(void (^)(NSError *error))completion;

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
