//
//  EZIoTRegisterVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/9/29.
//

#import "EZIoTRegisterVC.h"
#import <EZIoTUserSDK/EZIoTUserSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>
#import "EZIoTLoginHandle.h"


@interface EZIoTRegisterVC ()
@property (weak, nonatomic) IBOutlet UIButton *areaBtn;
@property (weak, nonatomic) IBOutlet UITextField *accountTextfield;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextfield;
@property (weak, nonatomic) IBOutlet UITextField *authCodeTextfield;

@end

@implementation EZIoTRegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *areaLabel = [NSString stringWithFormat:@"%@+%@", [EZIoTUserInfo getInstance].areaInfo.name, [EZIoTUserInfo getInstance].areaInfo.phoneCode];
    [self.areaBtn setTitle:[EZIoTUserInfo getInstance].areaInfo.name ? areaLabel : @"选择区域" forState:UIControlStateNormal];
}


- (IBAction)sendAuthCode:(id)sender {
 
    if (self.accountTextfield.text.length > 0)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self.view endEditing:YES];
        __weak typeof(self) weakSelf = self;
        [EZIoTUserAccountManager getSMSCodeWithAccount:self.accountTextfield.text phoneCode:[EZIoTUserInfo getInstance].areaInfo.phoneCode bizType:EZIoTUserBizTypeRegister success:^{
            
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.view makeToast:@"验证码发送成功" duration:3.0 position:CSToastPositionCenter];
            
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.view makeToast:error.localizedFailureReason  duration:3.0 position:CSToastPositionCenter];
        }];
    }
    else
    {
        [self.view makeToast:@"请输入手机号/邮箱" duration:3.0 position:CSToastPositionCenter];
    }
}

- (IBAction)registerBtn:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  
    if (self.authCodeTextfield.text.length > 0 && self.pwdTextfield.text.length > 0) {
        
        [self.view endEditing:YES];
        __weak typeof(self) weakSelf = self;
        [EZIoTUserAccountManager verifySmsCodeWithAccount:self.accountTextfield.text phoneCode:[EZIoTUserInfo getInstance].areaInfo.phoneCode smsCode:self.authCodeTextfield.text bizType: EZIoTUserBizTypeRegister success:^{
            
            [EZIoTUserAccountManager registWithAccount:weakSelf.accountTextfield.text password:weakSelf.pwdTextfield.text areaId:[EZIoTUserInfo getInstance].areaInfo.areaId phoneCode:[EZIoTUserInfo getInstance].areaInfo.phoneCode smsCode:weakSelf.authCodeTextfield.text success:^(EZIoTUserSessionInfo * _Nonnull sessionInfo) {
                
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf.view makeToast:@"注册成功" duration:3.0 position:CSToastPositionCenter];
                [EZIoTLoginHandle loginSuccessHandle];
                
            } failure:^(NSError * _Nonnull error) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常" duration:3.0 position:CSToastPositionCenter];
            }];
            
        } failure:^(NSError * _Nonnull error) {
            
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常" duration:3.0 position:CSToastPositionCenter];
        }];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


@end
