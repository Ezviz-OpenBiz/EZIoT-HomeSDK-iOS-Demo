//
//  EZIoTModifyRoomInfoVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/19.
//

#import "EZIoTModifyRoomInfoVC.h"
#import <EZIoTFamilySDK/EZIoTFamilySDK.h>
#import <EZIoTUserSDK/EZIoTUserInfo.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>

@interface EZIoTModifyRoomInfoVC ()
@property (weak, nonatomic) IBOutlet UITextField *roomNameInput;

@end

@implementation EZIoTModifyRoomInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.roomNameInput.placeholder = [EZIoTUserInfo getInstance].curGroupName;
}


- (IBAction)clickModifyBtn:(id)sender {
    
    if (self.roomNameInput.text.length == 0) {
        [self.view makeToast:@"请输入房间名称" duration:3.0 position:CSToastPositionCenter];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTRoomManager modifyRoomNameWithFamilyId:[EZIoTUserInfo getInstance].curFamilyId roomId:[EZIoTUserInfo getInstance].curGroupId roomName:self.roomNameInput.text success:^{
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:@"修改成功"  duration:3.0 position:CSToastPositionCenter];
        
        [EZIoTUserInfo getInstance].curGroupName = self.roomNameInput.text;
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"error: %@", error);
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

@end
