//
//  EZIoTModifyContactVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/28.
//

#import "EZIoTModifyContactVC.h"
#import <EZIoTUserSDK/EZIoTUserSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>

@interface EZIoTModifyContactVC ()

@property (weak, nonatomic) IBOutlet UITextField *oldContactVerifyInput;
@property (weak, nonatomic) IBOutlet UITextField *freshContactVerifyInput;
@property (weak, nonatomic) IBOutlet UITextField *freshContactIput;
@property (weak, nonatomic) IBOutlet UIButton *oldContactBtn;
@property (weak, nonatomic) IBOutlet UIButton *freshContactBtn;
@property (weak, nonatomic) IBOutlet UIButton *verifyOldContactBtn;
@property (weak, nonatomic) IBOutlet UIButton *verifyNewContactBtn;

@end

@implementation EZIoTModifyContactVC

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self.type isEqualToString:@"eve"]) {
        
        self.navigationItem.title = @"修改邮箱";
        self.oldContactVerifyInput.placeholder = @"请输入原邮箱收到的验证码";
        self.freshContactIput.placeholder = @"请输入新邮箱地址";
        self.freshContactVerifyInput.placeholder = @"请输入新邮箱收到的验证码";
        [self.oldContactBtn setTitle:@"获取原邮箱验证码" forState:UIControlStateNormal];
        [self.freshContactBtn setTitle:@"获取新邮箱验证码" forState:UIControlStateNormal];
        [self.verifyOldContactBtn setTitle:@"验证原邮箱验证码" forState:UIControlStateNormal];
        [self.verifyNewContactBtn setTitle:@"验证新邮箱验证码" forState:UIControlStateNormal];
    }
    else if ([self.type isEqualToString:@"evp"]) {
        
        self.navigationItem.title = @"修改邮箱";
        self.oldContactVerifyInput.placeholder = @"请输入原手机号收到的验证码";
        self.freshContactIput.placeholder = @"请输入新邮箱地址";
        self.freshContactVerifyInput.placeholder = @"请输入新邮箱收到的验证码";
        [self.oldContactBtn setTitle:@"获取原手机号验证码" forState:UIControlStateNormal];
        [self.verifyOldContactBtn setTitle:@"验证原手机号验证码" forState:UIControlStateNormal];
        [self.freshContactBtn setTitle:@"获取新邮箱验证码" forState:UIControlStateNormal];
        [self.verifyNewContactBtn setTitle:@"验证新邮箱验证码" forState:UIControlStateNormal];
    }
    else if ([self.type isEqualToString:@"pve"]) {
        
        self.navigationItem.title = @"修改手机号";
        self.oldContactVerifyInput.placeholder = @"请输入原邮箱收到的验证码";
        self.freshContactIput.placeholder = @"请输入新手机号";
        self.freshContactVerifyInput.placeholder = @"请输入新手机号收到的验证码";
        [self.oldContactBtn setTitle:@"获取原邮箱验证码" forState:UIControlStateNormal];
        [self.verifyOldContactBtn setTitle:@"验证原邮箱验证码" forState:UIControlStateNormal];
        [self.freshContactBtn setTitle:@"获取新手机号验证码" forState:UIControlStateNormal];
        [self.verifyNewContactBtn setTitle:@"验证新手机号验证码" forState:UIControlStateNormal];
    }
    else if ([self.type isEqualToString:@"pvp"]) {
        
        self.navigationItem.title = @"修改手机号";
        self.oldContactVerifyInput.placeholder = @"请输入原手机号收到的验证码";
        self.freshContactIput.placeholder = @"请输入新手机号";
        self.freshContactVerifyInput.placeholder = @"请输入新手机号收到的验证码";
        [self.oldContactBtn setTitle:@"获取原手机号验证码" forState:UIControlStateNormal];
        [self.verifyOldContactBtn setTitle:@"验证原手机号验证码" forState:UIControlStateNormal];
        [self.freshContactBtn setTitle:@"获取新手机号验证码" forState:UIControlStateNormal];
        [self.verifyNewContactBtn setTitle:@"验证新手机号验证码" forState:UIControlStateNormal];
    }
}

- (IBAction)clickOldContactBtn:(id)sender
{
    EZIoTUserBizType type = [self getOldCheckBizType];
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTUserAccountManager getSMSCodeWithAccount:[EZIoTUserInfo getInstance].account phoneCode:[EZIoTUserInfo getInstance].areaInfo.phoneCode bizType:type success:^{
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:@"下发成功"  duration:3.0 position:CSToastPositionCenter];
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

- (IBAction)clickVerifyOldContactBtn:(id)sender {
    
    if (self.oldContactVerifyInput.text.length == 0)
    {
        [self.view makeToast:@"输入内容为空" duration:3.0 position:CSToastPositionCenter];
        return;
    }
    
    EZIoTUserBizType type = [self getOldCheckBizType];
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTUserAccountManager verifySmsCodeWithAccount:[EZIoTUserInfo getInstance].account phoneCode:[EZIoTUserInfo getInstance].areaInfo.phoneCode smsCode:self.oldContactVerifyInput.text bizType:type success:^{
        [weakSelf.view endEditing:YES];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:@"验证成功"  duration:3.0 position:CSToastPositionCenter];
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

- (IBAction)clickNewContactBtn:(id)sender
{
    if (self.freshContactIput.text.length == 0)
    {
        [self.view makeToast:@"输入内容为空" duration:3.0 position:CSToastPositionCenter];
        return;
    }
    
    EZIoTUserBizType type = [self getNewCheckBizType];
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTUserAccountManager getSMSCodeWithAccount:self.freshContactIput.text phoneCode:[EZIoTUserInfo getInstance].areaInfo.phoneCode bizType:type success:^{
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:@"下发成功"  duration:3.0 position:CSToastPositionCenter];
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

- (IBAction)clickVerifyNewContactBtn:(id)sender {
 
    if (self.freshContactVerifyInput.text.length == 0)
    {
        [self.view makeToast:@"输入内容为空" duration:3.0 position:CSToastPositionCenter];
        return;
    }

    EZIoTUserBizType type = [self getNewCheckBizType];
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTUserAccountManager verifySmsCodeWithAccount:self.freshContactIput.text phoneCode:[EZIoTUserInfo getInstance].areaInfo.phoneCode smsCode:self.freshContactVerifyInput.text bizType:type success:^{
        [weakSelf.view endEditing:YES];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:@"验证成功"  duration:3.0 position:CSToastPositionCenter];
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

- (IBAction)clickConfirmBtn:(id)sender {
    
    if (self.oldContactVerifyInput.text.length == 0 || self.freshContactIput.text.length == 0 || self.freshContactVerifyInput.text.length == 0)
    {
        [self.view makeToast:@"请输入步骤输入内容" duration:3.0 position:CSToastPositionCenter];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if ([self.type isEqualToString:@"email"])
    {
        EZIoTUserContactModifyParam *param = [EZIoTUserContactModifyParam new];
        param.newEmail = self.freshContactIput.text;
        param.newEmailSMSkcode = self.freshContactVerifyInput.text;
        param.oldSMSType = 3;
        param.oldContactSMScode = self.oldContactVerifyInput.text;
        [EZIoTUserInfoManager modifyUserEmailAddressWithParam:param success:^{
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
    else
    {
        EZIoTUserContactModifyParam *param = [EZIoTUserContactModifyParam new];
        param.newPhone = self.freshContactIput.text;
        param.newPhoneSMScode = self.freshContactVerifyInput.text;
        param.oldSMSType = 1;
        param.oldContactSMScode = self.oldContactVerifyInput.text;
        [EZIoTUserInfoManager modifyUserPhoneNumberWithParam:param success:^{
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
}

- (EZIoTUserBizType) getOldCheckBizType
{
    if ([self.type isEqualToString:@"eve"]) {
        return EZIoTUserBizTypeUpdateEmailValidateOldEmail;
    }
    else if ([self.type isEqualToString:@"evp"]) {
        return EZIoTUserBizTypeUpdateEmailValidateOldPhone;
    }
    else if ([self.type isEqualToString:@"pve"]) {
        return EZIoTUserBizTypeUpdatePhoneValidateOldEmail;
    }
    else {//pvp
        return EZIoTUserBizTypeUpdatePhoneValidateOldPhone;
    }
}

- (EZIoTUserBizType) getNewCheckBizType
{
    if ([self.type isEqualToString:@"eve"] || [self.type isEqualToString:@"evp"]) {
        return EZIoTUserBizTypeUpdateEmailValidateNewEmail;
    }
    else {
        return EZIoTUserBizTypeUpdatePhoneValidateNewPhone;
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
