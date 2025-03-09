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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//连接蓝牙
- (IBAction)connectDevice:(id)sender {
    OLPBluetoothManager.shared.peripheralNamePrefix = @"OLEAP Archer";
}

//获取电量
- (IBAction)getBatteryLevel:(id)sender {
    [OLPBluetoothManager.shared.bluetoothHelper getPower:^(NSError * _Nonnull error, NSInteger power) {
        NSLog(@"Power:%ld%%", power);
    }];
    
}

//获取固件版本号
- (IBAction)getFirmwareVersion:(id)sender {
    [OLPBluetoothManager.shared.bluetoothHelper getFirmwareVersion:^(NSError * _Nonnull error, NSString * _Nonnull version) {
        NSLog(@"Firmware Version:%@", version);
    }];
}

- (IBAction)updateFireware:(id)sender {
//    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    NSString *filePath = [doc stringByAppendingPathComponent:@"OleapArcher_V2.3.22_250217_8074228262431177746.bin"];
//
//    [OLPBluetoothManager.shared.bluetoothHelper updateFirmware:filePath progress:^(NSUInteger totalSent, NSUInteger expectedSend) {
//        NSLog(@"进度：%.1f%%", totalSent*100.0 / expectedSend);
//    } completion:^(NSError * _Nullable error, id  _Nullable result) {
//        NSLog(@"Complete, error:%@ result:%@", error, result);
//    }];
}

- (IBAction)getFileInfo:(id)sender {
    [OLPBluetoothManager.shared.bluetoothHelper getFlashFileList:^(NSError * _Nonnull error, NSArray<OLPFileHeader *> *fileList) {
        NSLog(@"File List:%@", fileList);
    }];
}

@end
