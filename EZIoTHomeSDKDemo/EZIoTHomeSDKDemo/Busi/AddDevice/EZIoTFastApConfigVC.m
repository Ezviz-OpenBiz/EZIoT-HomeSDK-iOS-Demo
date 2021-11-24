//
//  EZIoTFastApConfigVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/19.
//

#import "EZIoTFastApConfigVC.h"
#import <EZIoTNetConfigSDK/EZIoTNetConfigSDK.h>
#import <EZIoTUserSDK/EZIoTUserSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>


@interface EZIoTFastApConfigVC ()

@property (weak, nonatomic) IBOutlet UITextField *wifiSsidInput;
@property (weak, nonatomic) IBOutlet UITextField *wifiPwdInput;
@property (weak, nonatomic) IBOutlet UIButton *startConfigBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopConfigBtn;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (nonatomic, copy) NSMutableString *logContent;
@property (strong, nonatomic) EZIoTConfigTokenInfo *tokenInfo;

@end

@implementation EZIoTFastApConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.logContent = [NSMutableString string];
    self.wifiSsidInput.text = @"ezviz_test";
    self.wifiPwdInput.text = @"test123+";
    
    __weak typeof(self) weakSelf = self;
    [[EZIoTNetConfigurator sharedNetConfigurator] getConfigTokenWithFamilyId:[EZIoTUserInfo getInstance].curFamilyId groupId:[EZIoTUserInfo getInstance].curGroupId success:^(EZIoTConfigTokenInfo * _Nonnull tokenInfo) {
       
        weakSelf.tokenInfo = tokenInfo;
        [weakSelf setDebugLog:[NSString stringWithFormat:@"\n请求成功：\n %@\n", tokenInfo]];
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        [weakSelf setDebugLog:[NSString stringWithFormat:@"\n请求失败：\n %@\n", error]];
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

- (IBAction)clickJumpToSystemPage:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:root=WIFI"] options:@{} completionHandler:^(BOOL success) {
            
    }];
}

- (IBAction)clickStartConfig:(UIButton *)sender {
    
    self.startConfigBtn.enabled = NO;
    self.stopConfigBtn.enabled = YES;
    
    if (self.wifiSsidInput.text.length == 0 && self.wifiPwdInput.text.length == 0) {
        [self.view makeToast:@"请输入路由器WiFi信息"  duration:3.0 position:CSToastPositionCenter];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[EZIoTNetConfigurator sharedNetConfigurator] getAccessDeviceInfoWithSuccess:^(EZIoTAPDevInfo * _Nonnull devInfo) {

        EZIoTFastAPConfigQueryParam *param = [EZIoTFastAPConfigQueryParam new];
        param.deviceSerial = devInfo.devSubserial;
        param.familyId = [EZIoTUserInfo getInstance].curFamilyId;
        param.tokenInfo = weakSelf.tokenInfo;
        param.wifiSsid = self.wifiSsidInput.text;
        param.wifiPwd = self.wifiPwdInput.text;
        
        [weakSelf setDebugLog:[NSString stringWithFormat:@"\n请求成功：\n %@\n", devInfo]];

        [[EZIoTNetConfigurator sharedNetConfigurator] startFastAPConfigAndQueryBindStatusWithParam:param success:^(EZIoTUserDeviceInfo * _Nonnull userDeviceInfo) {

            [weakSelf setDebugLog:[NSString stringWithFormat:@"\n配网成功：\n %@\n", userDeviceInfo]];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

        } failure:^(NSError * _Nonnull error) {
             
            [weakSelf setDebugLog:[NSString stringWithFormat:@"\n请求失败：\n %@\n", error]];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            NSLog(@"error: %@", error);
            if (error.code == 30101) { // query device info time out
                [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
            }
        }];

    } failure:^(NSError * _Nonnull error) {
        
        [weakSelf setDebugLog:[NSString stringWithFormat:@"\n请求失败：\n %@\n", error]];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"error: %@", error);
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

- (IBAction)clickStopConfig:(UIButton *)sender {
    
    self.startConfigBtn.enabled = YES;
    self.stopConfigBtn.enabled = NO;
    
    [[EZIoTNetConfigurator sharedNetConfigurator] stopFastAPConfig];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (void) setDebugLog:(NSString *)content {
    
    [self.logContent appendString:content];
    self.logTextView.text = self.logContent;
}

- (void)setLogContent:(NSMutableString *)logContent
{
    _logContent = [logContent mutableCopy];
}

@end
