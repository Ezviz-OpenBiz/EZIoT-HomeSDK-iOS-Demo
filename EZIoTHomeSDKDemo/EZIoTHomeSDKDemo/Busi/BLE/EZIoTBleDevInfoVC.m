//
//  EZIoTBleDevInfoVC.m
//  EZIoTHomeSDKDemo
//
//  Created by yuqian on 2022/3/16.
//

#import "EZIoTBleDevInfoVC.h"
#import <EZIoTBluetoothSDK/EZIoTPeripheral.h>

@interface EZIoTBleDevInfoVC ()

@property (weak, nonatomic) IBOutlet UILabel *cidLabel;
@property (weak, nonatomic) IBOutlet UILabel *devSerialLabel;
@property (weak, nonatomic) IBOutlet UILabel *pidLabel;
@property (weak, nonatomic) IBOutlet UILabel *macLabel;
@property (weak, nonatomic) IBOutlet UILabel *fmaskLabel;
@property (weak, nonatomic) IBOutlet UILabel *customName;

@end

@implementation EZIoTBleDevInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.cidLabel.text = self.ezPeripheral.cid?:@"None";
    self.devSerialLabel.text = self.ezPeripheral.devSerial?:@"None";
    self.pidLabel.text = self.ezPeripheral.pid?:@"None";
    self.macLabel.text = self.ezPeripheral.macAddr?:@"None";
    self.fmaskLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.ezPeripheral.fmask]?:@"None";
    self.customName.text = self.ezPeripheral.devCustomName?:@"None";
}
@end
