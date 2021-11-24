//
//  EZIoTLoginVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/6/7.
//

#import "EZIoTLoginVC.h"
#import <EZIoTBaseSDK/EZIoTNetworking.h>
#import <EZIoTUserSDK/EZIoTUserSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>
#import "EZIoTLoginHandle.h"


@interface EZIoTLoginVC ()

@property (weak, nonatomic) IBOutlet UIButton *areaBtn;
@property (weak, nonatomic) IBOutlet UITextField *accountTextfield;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextfield;

@end

@implementation EZIoTLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    [self fetchData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSString *areaLabel = [NSString stringWithFormat:@"%@+%@", [EZIoTUserInfo getInstance].areaInfo.name, [EZIoTUserInfo getInstance].areaInfo.phoneCode];
    [self.areaBtn setTitle:[EZIoTUserInfo getInstance].areaInfo.name ? areaLabel : @"选择区域" forState:UIControlStateNormal];
}

- (void) fetchData {
    
    __weak typeof(self) weakSelf = self;
    [EZIoTUserInfoManager getAreaInfoWithCountryCode:[EZIoTUserInfo getInstance].areaInfo.code ?: @"CN" success:^(EZIoTUserAreaInfo * _Nonnull areaInfo){
        
        [weakSelf updateAreaInfo:areaInfo];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void) updateAreaInfo:(EZIoTUserAreaInfo *)areaInfo {
    
    NSString *areaLabel = [NSString stringWithFormat:@"%@+%@", areaInfo.name, areaInfo.phoneCode];
    [self.areaBtn setTitle:areaLabel forState:UIControlStateNormal];
}

- (IBAction)login:(id)sender {
    
    if (self.accountTextfield.text.length > 0 && self.pwdTextfield.text.length > 0) {
        
        [self.view endEditing:YES];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __weak typeof(self) weakSelf = self;

        EZIoTUserLoginParam *loginParam = [EZIoTUserLoginParam new];
        loginParam.account = self.accountTextfield.text;
        loginParam.password = self.pwdTextfield.text;
        loginParam.phoneCode = [EZIoTUserInfo getInstance].areaInfo.phoneCode;
        [EZIoTUserAccountManager loginWithParam:loginParam success:^(EZIoTUserSessionInfo * _Nonnull sessionInfo, EZIoTUserTerminalInfo * _Nonnull terminalInfo) {
            
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf performSegueWithIdentifier:@"gotoHomepage" sender:nil];
            [EZIoTLoginHandle loginSuccessHandle];
            
        } failure:^(NSError * _Nonnull error, EZIoTUserTerminalInfo * _Nullable terminalInfo) {
            
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
