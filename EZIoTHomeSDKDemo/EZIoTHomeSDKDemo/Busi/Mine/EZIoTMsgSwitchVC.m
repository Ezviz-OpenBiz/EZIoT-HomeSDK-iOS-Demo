//
//  EZIoTMsgSwitchVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/11/2.
//

#import "EZIoTMsgSwitchVC.h"
#import <EZIoTMessageSDK/EZIoTMessageSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>


@interface EZIoTMsgSwitchVC ()

@property (weak, nonatomic) IBOutlet UISwitch *warningSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *systemSwitch;

@end

@implementation EZIoTMsgSwitchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTMessageManager getMessageNodisturbingStatusWithType:21 success:^(BOOL enableNoDisturb) {
        weakSelf.systemSwitch.on = !enableNoDisturb;
        
        [EZIoTMessageManager getMessageNodisturbingStatusWithType:24 success:^(BOOL enableNoDisturb) {
            weakSelf.warningSwitch.on = !enableNoDisturb;
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"error: %@", error);
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
        }];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

- (IBAction)waringSwitchValueChange:(UISwitch *)sender {

    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTMessageManager setMessageNodisturbingStatusWithType:24 enableNoDisturb:!sender.on success:^{
        [weakSelf.view makeToast:@"设置成功"  duration:3.0 position:CSToastPositionCenter];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
    
}

- (IBAction)systemSwitchValueChange:(UISwitch *)sender {
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTMessageManager setMessageNodisturbingStatusWithType:21 enableNoDisturb:!sender.on success:^{
        [weakSelf.view makeToast:@"设置成功"  duration:3.0 position:CSToastPositionCenter];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}


@end
