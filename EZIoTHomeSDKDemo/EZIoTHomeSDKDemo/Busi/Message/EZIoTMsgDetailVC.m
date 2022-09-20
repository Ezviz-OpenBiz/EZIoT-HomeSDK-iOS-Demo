//
//  EZIoTMsgDetailVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/21.
//

#import "EZIoTMsgDetailVC.h"
#import <EZIoTMessageSDK/EZIoTMsgInfo.h>
#import <EZIoTFamilySDK/EZIoTFamilySDK.h>
#import <EZIoTUserSDK/EZIoTUserInfo.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <MJExtension/MJExtension.h>
#import <Toast/Toast.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface EZIoTMsgDetailVC ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;
@property (weak, nonatomic) IBOutlet UIButton *refuseBtn;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;

@property (strong, nonatomic) NSDictionary *customDic;

@end

@implementation EZIoTMsgDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
#warning 图片下载逻辑，需要解密处理，需封装
    
    if ([self.msgInfo.ext.customerInfo containsString:@"familyId"] &&
        [self.msgInfo.ext.customerInfo containsString:@"memberId"] &&
        [self.msgInfo.ext.customerInfo containsString:@"familyName"])
    {
        self.customDic = self.msgInfo.ext.customerInfo.mj_JSONObject;
        self.agreeBtn.hidden = NO;
        self.refuseBtn.hidden = NO;
        [self getFamilyInviteStatus];
    }
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.msgInfo.pic?:self.msgInfo.defaultPic]  placeholderImage:[UIImage imageNamed:@"msgIcon"]];
    self.fromLabel.text = self.msgInfo.from.length > 0 ? [NSString stringWithFormat:@"%@%@", @"来自：", self.msgInfo.from] : @"";
    self.titleLabel.text = self.customDic.count > 0 ? [NSString stringWithFormat:@"%@-家庭:%@", self.msgInfo.title, self.customDic[@"familyName"]] : self.msgInfo.title;
    self.detailLabel.text = self.msgInfo.detail;
    self.timeLabel.text = self.msgInfo.timeStr;
}

- (void) getFamilyInviteStatus
{
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTFamilyManager getFamilyDetailInfoWithFamilyId:self.customDic[@"familyId"] success:^(EZIoTFamilyDetailInfo * _Nonnull familyDetailInfo) {
            
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (familyDetailInfo.inviteStatus == 1)
        {
            weakSelf.agreeBtn.hidden = YES;
            weakSelf.refuseBtn.hidden = YES;
            weakSelf.doneBtn.hidden = NO;
            [weakSelf.doneBtn setTitle:@"已加入" forState:UIControlStateNormal];
        }

    } failure:^(NSError * _Nonnull error) {
        
        NSString *errorMsg = error.localizedFailureReason;
        if (error.code == 31033 || error.code == 30027) {
            errorMsg = @"你已被移出家庭";
        }
        NSLog(@"error: %@", error);
        [weakSelf.view makeToast:errorMsg.length>0 ? errorMsg : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    }];
}

- (IBAction)clickAgreeBtn:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTFamilyManager memberInviteOperationWithFamilyId:self.customDic[@"familyId"] memberId:self.customDic[@"memberId"] status:1 success:^{
            
        weakSelf.agreeBtn.hidden = YES;
        weakSelf.refuseBtn.hidden = YES;
        weakSelf.doneBtn.hidden = NO;
        [weakSelf.doneBtn setTitle:@"已加入" forState:UIControlStateNormal];
        
        NSLog(@"已加入");
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:@"已加入"  duration:3.0 position:CSToastPositionCenter];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"error: %@", error);
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

- (IBAction)clickRefuseBtn:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTFamilyManager memberInviteOperationWithFamilyId:self.customDic[@"familyId"]
                                                 memberId:self.customDic[@"memberId"]
                                                   status:2
                                                  success:^{
            
        weakSelf.agreeBtn.hidden = YES;
        weakSelf.refuseBtn.hidden = YES;
        weakSelf.doneBtn.hidden = NO;
        [weakSelf.doneBtn setTitle:@"已拒绝" forState:UIControlStateNormal];
        
        NSLog(@"已拒绝");
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:@"已拒绝"  duration:3.0 position:CSToastPositionCenter];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"error: %@", error);
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

@end
