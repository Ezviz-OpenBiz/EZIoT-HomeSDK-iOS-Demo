//
//  EZIoTModifyPwdVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/28.
//

#import "EZIoTModifyPwdVC.h"
#import <EZIoTUserSDK/EZIoTUserSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>

@interface EZIoTModifyPwdVC ()

@property (weak, nonatomic) IBOutlet UITextField *oldPwdInput;
@property (weak, nonatomic) IBOutlet UITextField *freshPwdInput;

@end

@implementation EZIoTModifyPwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}
- (IBAction)clickModifyBtn:(id)sender {
    
    if (self.oldPwdInput.text.length == 0 || self.freshPwdInput.text.length == 0) {
        [self.view makeToast:@"新、老密码不能为空" duration:3.0 position:CSToastPositionCenter];
        return;
    }
    if ([self.oldPwdInput.text isEqualToString:self.freshPwdInput.text]) {
        [self.view makeToast:@"新、老密码不能相同" duration:3.0 position:CSToastPositionCenter];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTUserInfoManager modifyUserAccountPassword:self.oldPwdInput.text newPassword:self.freshPwdInput.text success:^{
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

@end
