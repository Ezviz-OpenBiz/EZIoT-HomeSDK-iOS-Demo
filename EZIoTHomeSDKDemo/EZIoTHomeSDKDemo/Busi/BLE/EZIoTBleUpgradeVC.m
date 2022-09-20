//
//  EZIoTBleUpgradeVC.m
//  EZIoTHomeSDKDemo
//
//  Created by yuqian on 2022/3/16.
//

#import "EZIoTBleUpgradeVC.h"
#import <EZIoTBluetoothSDK/EZIoTBluetoothSDK.h>
#import <EZIoTDeviceControlSDK/EZIoTDevUpgradeMgr.h>
#import <Toast/Toast.h>


@interface EZIoTBleUpgradeVC ()

@property (weak, nonatomic) IBOutlet UITextField *packageIntervalInput;
@property (weak, nonatomic) IBOutlet UITextField *payloadSizeInput;
@property (weak, nonatomic) IBOutlet UIButton *startUpgradeBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopUpgradeBtn;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation EZIoTBleUpgradeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.stopUpgradeBtn.alpha = 0.5;
    self.stopUpgradeBtn.userInteractionEnabled = NO;
}

- (IBAction)clickStartUpgradeBtn:(id)sender {
    
    self.startUpgradeBtn.alpha = 0.5;
    self.startUpgradeBtn.userInteractionEnabled = NO;
    
    self.stopUpgradeBtn.alpha = 1;
    self.stopUpgradeBtn.userInteractionEnabled = YES;
    
    __weak typeof(self) weakSelf = self;
    
    [EZIoTDevUpgradeMgr startUpgrade:@{@"channelType":@"BLE", @"mac":self.ezPeripheral.macAddr, @"pid":self.ezPeripheral.pid, @"version":@"v1.0.0", @"upgradeMcu":@YES} progress:^(double progress) {

        [weakSelf.progressView setProgress:progress];
        NSInteger perNumber = progress * 100;
        weakSelf.progressLabel.text = [NSString stringWithFormat:@"升级进度: %ld%%", (long)perNumber];

    } completion:^(BOOL status, NSError * _Nullable error) {

        if (error)
        {
            [weakSelf.view makeToast:error.localizedFailureReason  duration:3.0 position:CSToastPositionCenter];
        }
        else
        {
            [weakSelf.view makeToast:@"升级完成，设备准备重启"  duration:3.0 position:CSToastPositionCenter];
            weakSelf.progressLabel.text = [NSString stringWithFormat:@"升级进度: 100%%"];
        }
    }];
}

- (IBAction)clickStopUpgradeBtn:(id)sender {
    
    self.stopUpgradeBtn.alpha = 0.5;
    self.stopUpgradeBtn.userInteractionEnabled = NO;
    
    self.startUpgradeBtn.alpha = 1;
    self.startUpgradeBtn.userInteractionEnabled = YES;
    
    [EZIoTDevUpgradeMgr stopUpgrade:@{}];
}

@end
