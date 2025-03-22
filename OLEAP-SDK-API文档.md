
# OLEAP-SDK V1.0.0 API 文档

## 0. App Info 设置

增加以下键值：

```plaintext
Key:   Privacy - Bluetooth Always Usage Description  
Value: 需要通过您的蓝牙服务连接蓝牙耳机，是否允许开启蓝牙权限？
```

集成方式：

在 Xcode 中：  
`General -> Frameworks, Libraries, and Embedded Content -> "olpsdk.framework"`  
Embed 选项选择 **"Embed Without Signing"**

---

## 1. 连接蓝牙耳机

### 1.1 通过蓝牙设备名连接

```objc
OLPBluetoothManager.shared.peripheralNamePrefix = @"OLEAP Archer";
```

### 1.2 通过蓝牙设备 UUID 连接

```objc
OLPBluetoothManager.shared.targetUUID = @"0BC23930-177F-9DBE-2529-BAF4183DF100";
```

---

## 2. 获取蓝牙耳机连接状态

### 2.1 通过回调 Block 获取连接结果

```objc
OLPBluetoothManager.shared.helper.didConnectPeripheralBlock = ^(CBPeripheral * _Nonnull peripheral, NSError * _Nullable error) {
    error ? NSLog(@"连接失败，error:%@", error) : NSLog(@"%@已连接", peripheral.name);
};
```

### 2.2 获取设备名及连接状态

```objc
NSArray<NSString *> *states = @[@"断开", @"连接中", @"已连接", @"断开中"];
NSLog(@"蓝牙设备：%@ 连接状态：%@", 
    OLPBluetoothManager.shared.helper.connectedPeripheral.name, 
    states[OLPBluetoothManager.shared.helper.peripheralConnectState]);
```

---

## 3. 获取剩余电量（0~100）

```objc
[OLPBluetoothManager.shared.helper getPower:^(NSError *error, NSInteger power) {
    if (error) {
        NSLog(@"获取剩余电量失败，error:%@", error);
    } else {
        NSLog(@"剩余电量:%ld%%", power);
    }
}];
```

---

## 4. 获取固件版本号

```objc
[OLPBluetoothManager.shared.helper getFirmwareVersion:^(NSError * _Nonnull error, NSString * _Nonnull version) {
    if (error) {
        NSLog(@"获取固件版本号失败，error:%@", error);
    } else {
        NSLog(@"固件版本号:%@", version);
    }
}];
```

---

## 5. 固件更新

方法签名：

```objc
- (void)updateFirmware:(NSString *)filePath 
              progress:(OLPProgress)progress 
            completion:(OLPCallBack)completion;
```

调用示例：

```objc
[OLPBluetoothManager.shared.helper updateFirmware:filePath 
    progress:^(NSUInteger totalSent, NSUInteger expectedSend) {
        NSLog(@"进度：%.1f%%", totalSent * 100.0 / expectedSend);
    } 
    completion:^(NSError * _Nullable error, id  _Nullable result) {
        if (error) {
            NSLog(@"固件更新失败, error:%@", error);
        } else {
            NSLog(@"固件成功");
        }
    }];
```

---

## 6. 获取 Flash 文件列表

```objc
[OLPBluetoothManager.shared.helper getFlashFileList:^(NSError * _Nonnull error, NSArray<OLPFileHeader *> * _Nonnull fileList) {
    if (error) {
        NSLog(@"获取文件列表失败, error:%@", error);
    } else {
        NSInteger i = 1;
        for (OLPFileHeader *info in fileList) {
            NSLog(@"%ld.%@ 大小：%luKB 创建时间：%@", 
                i++, 
                OLP_RECORD_DESCS[@(info.recordType)], 
                info.filesize >> 10, 
                info.creatTime ?: @"未知");
        }
    }
}];
```

---

## 7. 获取耳机存储总容量与剩余容量

```objc
[OLPBluetoothManager.shared.helper getCapacity:^(NSError * _Nonnull error, NSArray<NSString *> * _Nonnull flashCapacity) {
    if (error) {
        NSLog(@"获取容量失败，error:%@", error);
    } else {
        NSLog(@"总容量：%@字节 剩余：%@字节", flashCapacity[0], flashCapacity[1]);
    }
}];
```

---

## 8. 下载首个文件并删除

```objc
NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
NSString *outputPath = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"download_%ld.opus", (NSUInteger)nowUTCSeconds()]];
[OLPBluetoothManager.shared.helper downloadFirstFlashFile:outputPath 
    progress:^(NSUInteger totalSent, NSUInteger expectedSend) {
        NSLog(@"进度：%.1f%%", totalSent * 100.0 / expectedSend);
    } 
    completion:^(NSError * _Nonnull error) {
        if (error) {
            NSLog(@"下载失败，error:%@", error);
        } else {
            NSLog(@"下载成功");
        }
    }];
```

---

## 9. 删除首个文件

```objc
[OLPBluetoothManager.shared.helper deleteFirstFlashFile:^(NSError * _Nonnull error) {
    if (error) {
        NSLog(@"删除失败，error:%@", error);
    } else {
        NSLog(@"删除成功");
    }
}];
```

---

## 10. 启动录音

```objc
NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
NSString *outputPath = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"record_%ld.opus", (NSUInteger)nowUTCSeconds()]];
[OLPBluetoothManager.shared.helper startRecordWithType:OLPRecordTypeANC 
    toOutputFilePath:outputPath 
    completion:^(NSError * _Nonnull error) {
        if (error) {
            NSLog(@"启动录音失败，error:%@", error);
        } else {
            NSLog(@"启动录音成功");
        }
    }];
```

---

## 11. 停止录音

```objc
[OLPBluetoothManager.shared.helper stopRecord:^(NSError * _Nonnull error) {
    if (error) {
        NSLog(@"停止录音失败，error:%@", error);
    } else {
        NSLog(@"停止录音成功");
    }
}];
```

---

## 12. OPUS 文件转码为 MP3 或 WAV

方法签名：

```objc
- (BOOL)decodeOpusFile:(NSString *)inputPath 
     toOutputFilePath:(NSString *)outputFilePath 
       withDecodeType:(OLPDecodeType)decodeType;
```

调用示例：

```objc
NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
NSString *opusPath = [doc stringByAppendingPathComponent:@"1.opus"];
NSString *wavPath = [opusPath stringByAppendingString:@".wav"];
NSString *mp3Path = [opusPath stringByAppendingString:@".mp3"];

BOOL ret = [OLPBluetoothManager.shared.helper decodeOpusFile:opusPath toOutputFilePath:wavPath withDecodeType:OLPDecodeTypeWAV];
NSLog(@"OPUS转WAV%@", ret ? @"成功" : @"失败");

ret = [OLPBluetoothManager.shared.helper decodeOpusFile:opusPath toOutputFilePath:mp3Path withDecodeType:OLPDecodeTypeMP3];
NSLog(@"OPUS转MP3%@", ret ? @"成功" : @"失败");
```
