//
//  ViewController.m
//  OLP-SDK
//
//  Created by drops on 2025/2/28.
//

#import "ViewController.h"
#import <olpsdk/OLPBluetoothHelper.h>
#import <olpsdk/OLPBluetoothManager.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *startOrStopRecordButton;
@property (assign, nonatomic) BOOL recording;
@property (assign, nonatomic) BOOL isReconnect;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.startOrStopRecordButton setTitle:@"开始录音" forState:UIControlStateNormal];
}

NSTimeInterval nowUTCSeconds(void) {
    return [[NSDate date]timeIntervalSince1970];
}

//连接蓝牙
- (IBAction)connectDevice:(id)sender {
    if (!self.isReconnect) {
        OLPBluetoothManager.shared.peripheralNamePrefix = @"OLEAP Archer";
        self.isReconnect = YES;
    } else {
        [OLPBluetoothManager.shared reconnect];
    }
    
    OLPBluetoothManager.shared.helper.didDiscoverPeripheralBlock = ^(CBPeripheral * _Nonnull peripheral) {
        NSLog(@"连接中...");
    };
    
    OLPBluetoothManager.shared.helper.didConnectPeripheralBlock = ^(CBPeripheral * _Nonnull peripheral, NSError * _Nullable error) {
        error ? NSLog(@"%@", error) : NSLog(@"%@已连接", peripheral.name);
    };
    
    NSArray<NSString *> *states = @[@"断开", @"连接中", @"已连接", @"断开中"];
    NSLog(@"蓝牙设备：%@ 连接状态：%@", OLPBluetoothManager.shared.helper.connectedPeripheral.name, states[OLPBluetoothManager.shared.helper.peripheralConnectState]);
}

//获取电量
- (IBAction)getBatteryLevel:(id)sender {
    [OLPBluetoothManager.shared.helper getPower:^(NSError *error, NSInteger power) {
        if (error) {
            NSLog(@"获取剩余电量失败，error:%@", error);
        } else {
            NSLog(@"剩余电量:%ld%%", power);
        }
    }];
}

//获取固件版本号
- (IBAction)getFirmwareVersion:(id)sender {
    [OLPBluetoothManager.shared.helper getFirmwareVersion:^(NSError * _Nonnull error, NSString * _Nonnull version) {
        if (error) {
            NSLog(@"获取固件版本号失败，error:%@", error);
        } else {
            NSLog(@"固件版本号:%@", version);
        }
    }];
}

//更新固件
- (IBAction)updateFireware:(id)sender {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [doc stringByAppendingPathComponent:@"OleapArcher_V2.3.22_250217_8074228262431177746.bin"];
    [OLPBluetoothManager.shared.helper updateFirmware:filePath progress:^(NSUInteger totalSent, NSUInteger expectedSend) {
        NSLog(@"进度：%.1f%%", totalSent*100.0 / expectedSend);
    } completion:^(NSError * _Nullable error, id  _Nullable result) {
        if (error) {
            NSLog(@"固件更新失败");
        } else {
            NSLog(@"固件成功");
        }
    }];
}

//文件列表
- (IBAction)getFileInfo:(id)sender {
    [OLPBluetoothManager.shared.helper getFlashFileList:^(NSError * _Nonnull error, NSArray<OLPFileHeader *> * _Nonnull fileList) {
        if (error) {
            NSLog(@"获取文件列表失败");
        } else {
            NSInteger i = 1;
            for (OLPFileHeader *info in fileList) {
                NSLog(@"%ld.%@ 大小：%luKB 创建时间：%@", i++, OLP_RECORD_DESCS[@(info.recordType)], info.filesize >> 10, info.creatTime ?: @"未知");
            }
        }
    }];
}

//下载文件到APP
- (IBAction)downloadFile:(id)sender {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *outputPath = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"download_%ld.opus", (NSUInteger)nowUTCSeconds()]];
    [OLPBluetoothManager.shared.helper downloadFirstFlashFile:outputPath progress:^(NSUInteger totalSent, NSUInteger expectedSend) {
        NSLog(@"进度：%.1f%%", totalSent*100.0 / expectedSend);
    } completion:^(NSError * _Nonnull error) {
        if (error) {
            NSLog(@"下载失败，error:%@", error);
        } else {
            NSLog(@"下载成功");
        }
    }];
}

//删除耳机中起始文件
- (IBAction)deleteFile:(id)sender {
    [OLPBluetoothManager.shared.helper deleteFirstFlashFile:^(NSError * _Nonnull error) {
        if (error) {
            NSLog(@"删除失败，error:%@", error);
        } else {
            NSLog(@"删除成功");
        }
    }];
}

//获取耳机总容量和剩余容量
- (IBAction)getCapacity:(id)sender {
    [OLPBluetoothManager.shared.helper getCapacity:^(NSError * _Nonnull error, NSArray<NSString *> * _Nonnull flashCapacity) {
        if (error) {
            NSLog(@"获取容量失败，error:%@", error);
        } else {
            NSLog(@"总容量：%@字节 剩余：%@字节", flashCapacity[0], flashCapacity[1]);
        }
    }];
}

- (IBAction)opus2mp3:(id)sender {
    NSString *testDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    [self test:testDir];
}

- (void)test:(NSString *)testDir {
    int ret = 0;
    NSArray *subPaths = [NSFileManager.defaultManager subpathsAtPath:testDir];
    NSLog(@"-------------------begin----------------");
    for (NSString *path in subPaths) {
        BOOL isDir = NO;
        NSString *opusPath = [testDir stringByAppendingPathComponent:path];
        if ([NSFileManager.defaultManager fileExistsAtPath:opusPath isDirectory:&isDir] && !isDir && [opusPath hasSuffix:@"opus"]) {
            NSString *wavPath = [opusPath stringByAppendingString:@".wav"];
            NSString *mp3Path = [opusPath stringByAppendingString:@".mp3"];
            
            ret = [OLPBluetoothManager.shared.helper decodeOpusFile:opusPath toOutputFilePath:wavPath withDecodeType:OLPDecodeTypeWAV];
            NSLog(@"ret:%d %@", ret, wavPath);
            ret = [OLPBluetoothManager.shared.helper decodeOpusFile:opusPath toOutputFilePath:mp3Path withDecodeType:OLPDecodeTypeMP3];
            NSLog(@"ret:%d %@", ret, mp3Path);
        }
    }
    
    NSLog(@"-------------------end----------------");
}

//开始、结束录音
- (IBAction)startOrStopRecord:(id)sender {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *outputPath = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"record_%ld.opus", (NSUInteger)nowUTCSeconds()]];
    if (self.recording) {
        [OLPBluetoothManager.shared.helper stopRecord:^(NSError * _Nonnull error) {
            [self.startOrStopRecordButton setTitle:@"开始录音" forState:UIControlStateNormal];
            if (error) {
                NSLog(@"停止录音失败，error:%@", error);
            } else {
                NSLog(@"停止录音成功");
            }
        }];
    } else {
        [OLPBluetoothManager.shared.helper startRecordWithType:OLPRecordTypeANC toOutputFilePath:outputPath completion:^(NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.startOrStopRecordButton setTitle:@"录音中" forState:UIControlStateNormal];
                if (error) {
                    NSLog(@"StartRecord:%@", error);
                }
            });
        }];
    }
    
    self.recording = !self.recording;
}

@end
