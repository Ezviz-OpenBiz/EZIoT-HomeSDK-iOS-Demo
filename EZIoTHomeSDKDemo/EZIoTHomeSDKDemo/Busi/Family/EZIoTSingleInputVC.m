//
//  EZIoTSingleInputVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/27.
//

#import "EZIoTSingleInputVC.h"
#import <EZIoTFamilySDK/EZIoTFamilySDK.h>
#import <EZIoTUserSDK/EZIoTUserSDK.h>
#import <EZIoTDeviceSDK/EZIoTDeviceSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>

@interface EZIoTSingleInputVC ()

@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end

@implementation EZIoTSingleInputVC

- (void)viewDidLoad {
    [super viewDidLoad];

    //Family
    if ([self.type isEqualToString:@"ModifyFamilyName"]) {
        self.navigationItem.title = @"修改家庭名称";
        self.inputField.placeholder = @"请输入家庭名称";
        [self.confirmBtn setTitle:@"修改" forState:UIControlStateNormal];
    }
    else if ([self.type isEqualToString:@"AddMember"]) {
        self.navigationItem.title = @"邀请家庭成员";
        self.inputField.placeholder = @"请输入对方注册手机号或邮箱";
        [self.confirmBtn setTitle:@"邀请" forState:UIControlStateNormal];
    }
    else if ([self.type isEqualToString:@"ModifyMemberName"]) {
        self.navigationItem.title = @"修改成员名称";
        self.inputField.placeholder = @"请输入成员名称";
        [self.confirmBtn setTitle:@"修改" forState:UIControlStateNormal];
    }
    
    //UserInfo
    else if ([self.type isEqualToString:@"ModifyNickname"]) {
        self.navigationItem.title = @"修改昵称";
        self.inputField.placeholder = @"请输入昵称，长度在2~60个字之间";
        [self.confirmBtn setTitle:@"修改" forState:UIControlStateNormal];
    }
    else if ([self.type isEqualToString:@"ModifyBirth"]) {
        self.navigationItem.title = @"修改生日";
        self.inputField.placeholder = @"修改生日，格式为1999-05-03";
        [self.confirmBtn setTitle:@"修改" forState:UIControlStateNormal];
    }
    else if ([self.type isEqualToString:@"ModifyDevName"]) {
        self.navigationItem.title = @"修改设备名称";
        self.inputField.placeholder = @"请输入设备名称";
        [self.confirmBtn setTitle:@"修改" forState:UIControlStateNormal];
    }
    else if ([self.type isEqualToString:@"ModifyResourceName"]) {
        self.navigationItem.title = @"修改资源名称";
        self.inputField.placeholder = @"请输入资源名称";
        [self.confirmBtn setTitle:@"修改" forState:UIControlStateNormal];
    }
}

- (IBAction)clickCreateFamilyBtn:(id)sender {
    
    if (self.inputField.text.length == 0) {
        if ([self.type isEqualToString:@"ModifyFamilyName"]) {
            [self.view makeToast:@"请输入家庭名称" duration:3.0 position:CSToastPositionCenter];
        }
        else if ([self.type isEqualToString:@"AddMember"]) {
            [self.view makeToast:@"请输入对方注册手机号或邮箱" duration:3.0 position:CSToastPositionCenter];
        }
        else if ([self.type isEqualToString:@"ModifyMemberName"]) {
            [self.view makeToast:@"请输入家庭成员名称" duration:3.0 position:CSToastPositionCenter];
        }
        else if ([self.type isEqualToString:@"ModifyNickname"]) {
            [self.view makeToast:@"请输入昵称" duration:3.0 position:CSToastPositionCenter];
        }
        else if ([self.type isEqualToString:@"ModifyBirth"]) {
            [self.view makeToast:@"请输入生日" duration:3.0 position:CSToastPositionCenter];
        }
        else if ([self.type isEqualToString:@"ModifyDevName"]) {
            [self.view makeToast:@"请输入设备名称" duration:3.0 position:CSToastPositionCenter];
        }
        else if ([self.type isEqualToString:@"ModifyResourceName"]) {
            [self.view makeToast:@"请输入资源名称" duration:3.0 position:CSToastPositionCenter];
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if ([self.type isEqualToString:@"ModifyFamilyName"])
    {
        [EZIoTFamilyManager modifyFamilyNameWithFamilyId:[EZIoTUserInfo getInstance].curFamilyId familyName:self.inputField.text success:^{
            
            [weakSelf.view endEditing:YES];
            
            [weakSelf.navigationController.view makeToast:@"修改成功"  duration:3.0 position:CSToastPositionCenter];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
            
        } failure:^(NSError * _Nonnull error) {
            
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
        }];
    }
    else if ([self.type isEqualToString:@"AddMember"])
    {
        [EZIoTFamilyManager inviteFamilyMemberWithFamilyId:[EZIoTUserInfo getInstance].curFamilyId invitedAccount:self.inputField.text success:^{
            
            [weakSelf.view endEditing:YES];
            
            [weakSelf.navigationController.view makeToast:@"邀请成功"  duration:2.0 position:CSToastPositionCenter];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
            
        } failure:^(NSError * _Nonnull error) {
            
            [weakSelf.view endEditing:YES];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
        }];
    }
    else if ([self.type isEqualToString:@"ModifyMemberName"])
    {
        [EZIoTFamilyManager modifyMemberNickNameWithFamilyId:[EZIoTUserInfo getInstance].curFamilyId memberId:self.memberInfo.identifier nickname:self.inputField.text success:^{
            [weakSelf.view endEditing:YES];
            
            [weakSelf.navigationController.view makeToast:@"修改成功"  duration:2.0 position:CSToastPositionCenter];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
            
        } failure:^(NSError * _Nonnull error) {
            
            [weakSelf.view endEditing:YES];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
        }];
    }
    else if ([self.type isEqualToString:@"ModifyNickname"])
    {
        [EZIoTUserInfoManager modifyUserNickname:self.inputField.text success:^{
            [weakSelf.view endEditing:YES];
            
            [weakSelf.navigationController.view makeToast:@"修改成功"  duration:2.0 position:CSToastPositionCenter];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
            
        } failure:^(NSError * _Nonnull error) {
            
            [weakSelf.view endEditing:YES];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
        }];
    }
    else if ([self.type isEqualToString:@"ModifyBirth"])
    {
        [EZIoTUserInfoManager modifyUserBirthDate:self.inputField.text success:^{
            [weakSelf.view endEditing:YES];
            
            [weakSelf.navigationController.view makeToast:@"修改成功"  duration:2.0 position:CSToastPositionCenter];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
            
        } failure:^(NSError * _Nonnull error) {
            
            [weakSelf.view endEditing:YES];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
        }];
    }
    else if ([self.type isEqualToString:@"ModifyDevName"]) {
        
        [EZIoTDeviceManager modifyDeviceName:self.inputField.text deviceSerial:self.deviceInfo.deviceSerial success:^{
            
            [weakSelf.view endEditing:YES];
            weakSelf.deviceInfo.name = weakSelf.inputField.text;
            [weakSelf.navigationController.view makeToast:@"修改成功"  duration:2.0 position:CSToastPositionCenter];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        } failure:^(NSError * _Nonnull error) {
            [weakSelf.view endEditing:YES];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
        }];
    }
    else if ([self.type isEqualToString:@"ModifyResourceName"]) {
        
        [EZIoTDeviceManager modifyResourceName:self.inputField.text resourceId:self.deviceInfo.resourceInfos.firstObject.resourceId success:^{
            
            [weakSelf.view endEditing:YES];
            weakSelf.deviceInfo.resourceInfos.firstObject.name = weakSelf.inputField.text;
            [weakSelf.navigationController.view makeToast:@"修改成功"  duration:2.0 position:CSToastPositionCenter];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        } failure:^(NSError * _Nonnull error) {
            [weakSelf.view endEditing:YES];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
        }];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
