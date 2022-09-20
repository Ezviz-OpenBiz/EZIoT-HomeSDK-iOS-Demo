//
//  EZIoTBleDevMainVC.m
//  EZIoTHomeSDKDemo
//
//  Created by yuqian on 2022/3/16.
//

#import "EZIoTBleDevMainVC.h"
#import "EZIoTBleControlVC.h"
#import "EZIoTBleUpgradeVC.h"
#import "EZIoTBleDevInfoVC.h"
#import "EZIoTBleWiFiConfigVC.h"
#import <Toast/Toast.h>
#import <EZIoTBluetoothSDK/EZIoTBluetoothSDK.h>

@interface EZIoTBleDevMainVC ()

@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UIButton *disconnectBtn;

@end

@implementation EZIoTBleDevMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.ezPeripheral.devName;
    
    self.disconnectBtn.alpha = 0.5;
    self.disconnectBtn.userInteractionEnabled = NO;
}

- (IBAction)clickConnectBtn:(UIButton *)sender {
    
    self.connectBtn.alpha = 0.5;
    self.connectBtn.userInteractionEnabled = NO;
    
    self.disconnectBtn.alpha = 1;
    self.disconnectBtn.userInteractionEnabled = YES;
    
    __weak typeof(self) weakSelf = self;
//    [[EZIoTBLECenterMgr sharedInstance] connectAuth:self.ezPeripheral.devSerial success:^(EZIoTPeripheral * _Nullable peripheral) {
//
//        [[EZIoTBLECenterMgr sharedInstance] stopScan];
//        [weakSelf.connectBtn setTitle:@"已连接(认证成功)" forState:UIControlStateNormal];
//
//    } failure:^(EZIoTPeripheral * _Nullable peripheral, NSError * _Nullable error) {
//        [weakSelf.connectBtn setTitle:@"已连接(认证失败)" forState:UIControlStateNormal];
//    }];
    
    [[EZIoTBLECenterMgr sharedInstance] connectPeripheral:self.ezPeripheral success:^(EZIoTPeripheral * _Nonnull peripheral) {

        NSLog(@"Connected peripheral : %@", peripheral);
        [weakSelf.connectBtn setTitle:@"已连接(双向认证中...)" forState:UIControlStateNormal];

        [[EZIoTBLECenterMgr sharedInstance] stopScan];
        [[EZIoTBLECenterMgr sharedInstance] startDoubleAuthentication:peripheral.peripheral.identifier.UUIDString completion:^(BOOL status, int failType, NSDictionary *_Nullable statistics, NSError * _Nullable error) {
            if (status) {
                [weakSelf.connectBtn setTitle:@"已连接(认证成功)" forState:UIControlStateNormal];
                [[EZIoTBLECenterMgr sharedInstance] trashCompensation:peripheral localIndex:@"0" devTimezone:@"UTC+8:00" completion:^(BOOL status, NSError * _Nonnull error) {
                                    
                }];
            }
            else
                [weakSelf.connectBtn setTitle:@"已连接(认证失败)" forState:UIControlStateNormal];
        }];

    } failure:^(EZIoTPeripheral * _Nullable peripheral, NSError * _Nullable error) {
        NSLog(@"DisConnected peripheral : %@, error:%@", peripheral, error);
    }];
}

- (IBAction)clickDisConnectBtn:(id)sender {
    
    self.disconnectBtn.alpha = 0.5;
    self.disconnectBtn.userInteractionEnabled = NO;
    
    self.connectBtn.alpha = 1;
    self.connectBtn.userInteractionEnabled = YES;
    
    __weak typeof(self) weakSelf = self;
    [[EZIoTBLECenterMgr sharedInstance] stopConnect:self.ezPeripheral complement:^(EZIoTPeripheral * _Nullable peripheral, NSError * _Nullable error) {
        
        if (!error) {
            [weakSelf.connectBtn setTitle:@"开始连接" forState:UIControlStateNormal];
        }
        NSLog(@"DisConnected peripheral : %@", peripheral);
    }];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[EZIoTBleControlVC class]])
    {
        EZIoTBleControlVC *vc = segue.destinationViewController;
        vc.ezPeripheral = self.ezPeripheral;
    }
    else if ([segue.destinationViewController isKindOfClass:[EZIoTBleUpgradeVC class]])
    {
        EZIoTBleUpgradeVC *vc = segue.destinationViewController;
        vc.ezPeripheral = self.ezPeripheral;
    }
    else if ([segue.destinationViewController isKindOfClass:[EZIoTBleDevInfoVC class]])
    {
        EZIoTBleDevInfoVC *vc = segue.destinationViewController;
        vc.ezPeripheral = self.ezPeripheral;
    }
    else if ([segue.destinationViewController isKindOfClass:[EZIoTBleWiFiConfigVC class]])
    {
        EZIoTBleDevInfoVC *vc = segue.destinationViewController;
        vc.ezPeripheral = self.ezPeripheral;
    }
}


@end
