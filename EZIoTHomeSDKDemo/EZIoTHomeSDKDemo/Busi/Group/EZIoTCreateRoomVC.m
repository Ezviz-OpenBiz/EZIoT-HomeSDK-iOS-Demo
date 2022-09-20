//
//  EZIoTCreateRoomVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/18.
//

#import "EZIoTCreateRoomVC.h"
#import <EZIoTFamilySDK/EZIoTFamilySDK.h>
#import <EZIoTUserSDK/EZIoTUserInfo.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>


@interface EZIoTCreateRoomVC ()

@property (weak, nonatomic) IBOutlet UITextField *roomNameInput;

@end

@implementation EZIoTCreateRoomVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)clickCreateRoomBtn:(id)sender {
    
    if (self.roomNameInput.text.length == 0) {
        [self.view makeToast:@"请输入房间名称" duration:3.0 position:CSToastPositionCenter];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTRoomManager createRoomWithFamilyId:[EZIoTUserInfo getInstance].curFamilyId roomName:self.roomNameInput.text success:^(NSString * _Nonnull groupId) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:@"创建成功"  duration:3.0 position:CSToastPositionCenter];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
