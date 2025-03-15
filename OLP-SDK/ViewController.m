//
//  ViewController.m
//  OLP-SDK
//
//  Created by drops on 2025/2/28.
//

#import "ViewController.h"
#import "olpsdk/OLPBluetoothHelper.h"
#import "OLPBluetoothManager.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *startOrStopRecordButton;
@property (strong, nonatomic) dispatch_queue_t queue;
@property (assign, nonatomic) BOOL recording;
@property (assign, nonatomic) BOOL isReconnect;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.startOrStopRecordButton setTitle:@"开始录音" forState:UIControlStateNormal];
    self.queue = dispatch_queue_create("com.olp.test", DISPATCH_QUEUE_SERIAL);
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
    
}

//获取电量
- (IBAction)getBatteryLevel:(id)sender {
    dispatch_async(self.queue, ^{
        [OLPBluetoothManager.shared.bluetoothHelper getPower:^(NSError * _Nonnull error, NSInteger power) {
            NSLog(@"Power:%ld%%", power);
        }];
    });
}

//获取固件版本号
- (IBAction)getFirmwareVersion:(id)sender {
    dispatch_async(self.queue, ^{
        [OLPBluetoothManager.shared.bluetoothHelper getFirmwareVersion:^(NSError * _Nonnull error, NSString * _Nonnull version) {
            NSLog(@"Firmware Version:%@", version);
        }];
    });
}

//更新固件
- (IBAction)updateFireware:(id)sender {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [doc stringByAppendingPathComponent:@"OleapArcher_V2.3.22_250217_8074228262431177746.bin"];
    dispatch_async(self.queue, ^{
        [OLPBluetoothManager.shared.bluetoothHelper updateFirmware:filePath progress:^(NSUInteger totalSent, NSUInteger expectedSend) {
            NSLog(@"进度：%.1f%%", totalSent*100.0 / expectedSend);
        } completion:^(NSError * _Nullable error, id  _Nullable result) {
            NSLog(@"Complete, error:%@ result:%@", error, result);
        }];
    });
}

//文件列表
- (IBAction)getFileInfo:(id)sender {
    dispatch_async(self.queue, ^{
        [OLPBluetoothManager.shared.bluetoothHelper getFlashFileList:^(NSError * _Nonnull error, NSArray<OLPFileHeader *> * _Nonnull fileList) {
            NSInteger i = 1;
            for (OLPFileHeader *info in fileList) {
                NSLog(@"%ld.%@ 大小：%lukB 创建时间：%@", i++, OLP_RECORD_DESCS[@(info.recordType)], info.filesize >> 10, info.creatTime ?: @"未知");
            }
        }];
    });
}

//下载文件到APP
- (IBAction)downloadFile:(id)sender {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *outputPath = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"download_%ld.opus", (NSUInteger)nowUTCSeconds()]];
//    NSString *outputPath = [doc stringByAppendingPathComponent:@"download_1742001426.opus"];
    dispatch_async(self.queue, ^{
        [OLPBluetoothManager.shared.bluetoothHelper downloadFirstFlashFile:outputPath progress:^(NSUInteger totalSent, NSUInteger expectedSend) {
            NSLog(@"进度：%.1f%%", totalSent*100.0 / expectedSend);
        } completion:^(NSError * _Nonnull error) {
            NSLog(@"下载%@", !error ? @"成功" : error);
        }];
    });
}

//删除耳机中起始文件
- (IBAction)deleteFile:(id)sender {
    dispatch_async(self.queue, ^{
        [OLPBluetoothManager.shared.bluetoothHelper deleteFirstFlashFile:^(NSError * _Nonnull error) {
            NSLog(@"删除%@", !error ? @"成功" : error);
        }];
    });
}

//获取耳机总容量和剩余容量
- (IBAction)getCapacity:(id)sender {
    [OLPBluetoothManager.shared.bluetoothHelper getCapacity:^(NSError * _Nonnull error, NSArray<NSString *> * _Nonnull flashCapacity) {
        NSLog(@"总容量：%@字节 剩余：%@字节", flashCapacity[0], flashCapacity[1]);
    }];
}

- (IBAction)opus2mp3:(id)sender {
    NSString *testDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"opus"];
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
            
            ret = [OLPBluetoothManager.shared.bluetoothHelper decodeOpusFile:opusPath toOutputFilePath:wavPath withDecodeType:OLPDecodeTypeWAV];
            NSLog(@"ret:%d %@", ret, wavPath);
            ret = [OLPBluetoothManager.shared.bluetoothHelper decodeOpusFile:opusPath toOutputFilePath:mp3Path withDecodeType:OLPDecodeTypeMP3];
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
        [OLPBluetoothManager.shared.bluetoothHelper stopRecord:^(NSError * _Nonnull error) {
            [self.startOrStopRecordButton setTitle:@"开始录音" forState:UIControlStateNormal];
            if (error) {
                NSLog(@"StopRecord:%@", error);
            }
        }];
    } else {
        [OLPBluetoothManager.shared.bluetoothHelper startRecordWithType:OLPRecordTypeANC toOutputFilePath:outputPath completion:^(NSError * _Nonnull error) {
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
