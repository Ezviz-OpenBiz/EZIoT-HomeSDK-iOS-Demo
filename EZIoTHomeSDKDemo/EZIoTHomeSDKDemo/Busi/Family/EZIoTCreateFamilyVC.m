//
//  EZIoTCreateFamilyVC.m
//  EZIoTSmartSDKDemo
//
//  Created by PiZ on 2021/10/1.
//

#import "EZIoTCreateFamilyVC.h"
#import <EZIoTFamilySDK/EZIoTFamilySDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>

@interface EZIoTCreateFamilyVC ()

@property (weak, nonatomic) IBOutlet UITextField *familyNameInput;

@end

@implementation EZIoTCreateFamilyVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)clickCreateFamilyBtn:(id)sender {
    
    if (self.familyNameInput.text.length == 0) {
        [self.view makeToast:@"请输入家庭名称" duration:3.0 position:CSToastPositionCenter ];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTFamilyManager createFamilyWithName:self.familyNameInput.text success:^(EZIoTFamilyInfo * _Nonnull familyInfo) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:@"创建成功"  duration:3.0 position:CSToastPositionCenter];
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

@end
