//
//  EZIoTResetPwdVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/9/29.
//

#import "EZIoTResetPwdVC.h"
#import <EZIoTUserSDK/EZIoTUserSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>

@interface EZIoTResetPwdVC ()

@property (weak, nonatomic) IBOutlet UIButton *areaBtn;
@property (weak, nonatomic) IBOutlet UITextField *accountTextfield;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextfield;
@property (weak, nonatomic) IBOutlet UITextField *authCodeTextfield;

@end

@implementation EZIoTResetPwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *areaLabel = [NSString stringWithFormat:@"%@+%@", [EZIoTUserInfo getInstance].areaInfo.name, [EZIoTUserInfo getInstance].areaInfo.phoneCode];
    [self.areaBtn setTitle:[EZIoTUserInfo getInstance].areaInfo.name ? areaLabel : @"选择区域" forState:UIControlStateNormal];
}

- (IBAction)sendAuthCode:(id)sender {
 
    if (self.accountTextfield.text.length > 0) {
        [self.view endEditing:YES];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        __weak typeof(self) weakSelf = self;
        [EZIoTUserAccountManager getSMSCodeWithAccount:self.accountTextfield.text phoneCode:[EZIoTUserInfo getInstance].areaInfo.phoneCode bizType:EZIoTUserBizTypeRetrievePassword success:^{
            
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.view makeToast:@"验证码发送成功" duration:3.0 position:CSToastPositionCenter];
            
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.view makeToast:error.localizedFailureReason];
        }];
    }
    else
    {
        [self.view makeToast:@"请输入手机号/邮箱" duration:3.0 position:CSToastPositionCenter];
    }
}

- (IBAction)resetBtn:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self.view endEditing:YES];
    if (self.authCodeTextfield.text.length > 0 && self.pwdTextfield.text.length > 0) {
        
        __weak typeof(self) weakSelf = self;
        [EZIoTUserAccountManager verifySmsCodeWithAccount:self.accountTextfield.text phoneCode:[EZIoTUserInfo getInstance].areaInfo.phoneCode smsCode:self.authCodeTextfield.text bizType: EZIoTUserBizTypeRetrievePassword success:^{
            
            [EZIoTUserAccountManager resetPasswordWithAccount:weakSelf.accountTextfield.text password:weakSelf.pwdTextfield.text phoneCode:[EZIoTUserInfo getInstance].areaInfo.phoneCode smsCode:weakSelf.authCodeTextfield.text success:^{
                
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf.view makeToast:@"密码修改成功" duration:3.0 position:CSToastPositionCenter];

                [weakSelf.navigationController popViewControllerAnimated:YES];
                
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
