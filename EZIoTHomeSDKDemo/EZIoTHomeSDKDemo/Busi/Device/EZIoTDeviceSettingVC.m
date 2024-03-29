//
//  EZIoTDeviceSettingVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/22.
//

#import "EZIoTDeviceSettingVC.h"
#import <EZIoTDeviceSDK/EZIoTDeviceSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>
#import "EZIoTSingleInputVC.h"
#import "EZIoTVideoPlayerVC.h"
#import "EZIoTRecordListVC.h"
//#import <EZIoTRouter/EZIoTPageResolver.h>

@interface EZIoTDeviceSettingVC ()

@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *resouceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *snLabel;
@property (weak, nonatomic) IBOutlet UILabel *VersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *OfflineTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *netTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *ssidLabel;
@property (weak, nonatomic) IBOutlet UILabel *ipLabel;
@property (weak, nonatomic) IBOutlet UILabel *maskLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (strong, nonatomic) EZIoTResourceInfo *resourceInfo;

@end

@implementation EZIoTDeviceSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.resourceInfo = [EZIoTResourceInfo getResourcesByDeviceSerial:self.deviceInfo.deviceSerial].firstObject;
    self.navigationItem.title = self.deviceInfo.name;
    self.deviceNameLabel.text = self.deviceInfo.name;
    self.resouceNameLabel.text = self.resourceInfo.name;
    self.snLabel.text = self.deviceInfo.deviceSerial;
    self.VersionLabel.text = self.deviceInfo.version;
    self.statusLabel.text = self.deviceInfo.status == 1 ? @"在线" : @"离线";
    self.typeLabel.text = self.deviceInfo.deviceType;
    self.OfflineTimeLabel.text = self.deviceInfo.offlineTime;
    self.netTypeLabel.text = self.deviceInfo.wifiInfo.netType?:@"none";
    self.ipLabel.text = self.deviceInfo.wifiInfo.addr?:@"none";
    self.maskLabel.text = self.deviceInfo.wifiInfo.mask?:@"none";
    self.ssidLabel.text = self.deviceInfo.wifiInfo.ssid?:@"none";
    
    if (self.resourceInfo.isShared != 0)
    {
        self.deleteBtn.enabled = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.deviceNameLabel.text = self.deviceInfo.name;
    self.resouceNameLabel.text = self.resourceInfo.name;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        [self performSegueWithIdentifier: @"ShowPlayVC" sender:@"Preview"];
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        [self performSegueWithIdentifier: @"ShowRecordListVC" sender:@"Device"];
    }
    else if (indexPath.section == 0 && indexPath.row == 2)
    {
        [self performSegueWithIdentifier: @"ShowRecordListVC" sender:@"Cloud"];
    }
    else if (indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 1)) {
        
        if (self.resourceInfo.isShared == 0) {
            EZIoTSingleInputVC *vc = [[UIStoryboard storyboardWithName:@"Family" bundle:nil] instantiateViewControllerWithIdentifier:@"EZIoTSingleInputVC"];
            switch (indexPath.row) {
                case 0:
                    vc.type = @"ModifyDevName";
                    vc.deviceInfo = self.deviceInfo;
                    break;
                case 1:
                    vc.type = @"ModifyResourceName";
                    vc.deviceInfo = self.deviceInfo;
                    break;
                default:
                    break;
            }
            [self.navigationController pushViewController:vc animated:YES];
        }
        else{
            [self.view makeToast:@"需要家庭主人操作"  duration:3.0 position:CSToastPositionCenter];
        }
    }
    else if (indexPath.section == 2)
    {
        NSData *jsonData = [self.deviceInfo.rnPackage dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        
        NSLog(@"Native Package:%@", self.deviceInfo.rnPackage);
        
        if (!dic || ![dic[@"rn_name"] isEqualToString:@"nativePanel"] || !dic[@"config"]) {
            [self.view makeToast:@"未配置原生面板"  duration:3.0 position:CSToastPositionCenter];
            return;
        }
        
        NSData *jsonData1 = [dic[@"config"] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err1;
        NSDictionary *dic1 = [NSJSONSerialization JSONObjectWithData:jsonData1
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err1];
        
        if (!dic1[@"payload"]) {
            [self.view makeToast:@"未配置原生面板"  duration:3.0 position:CSToastPositionCenter];
            return;
        }
        
//        UIViewController *customPanel = [EZIoTPageResolver pageRoute:[NSURL URLWithString:dic1[@"payload"]]];
//        if (!customPanel) {
//            [self.view makeToast:@"原生未实现该面板"  duration:3.0 position:CSToastPositionCenter];
//            return;
//        }
        
//        [self.navigationController pushViewController:customPanel animated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[EZIoTVideoPlayerVC class]]) {
        EZIoTVideoPlayerVC *vc = segue.destinationViewController;
        vc.deviceInfo = self.deviceInfo;
        vc.playeType = sender;
    }
    else
    {
        EZIoTRecordListVC *vc = segue.destinationViewController;
        vc.deviceInfo = self.deviceInfo;
        vc.recordType = sender;
    }
}

- (IBAction)clickDeleteBtn:(id)sender {
    
    if (self.resourceInfo.isShared == 0)
    {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"是否确认删除设备？" message:nil preferredStyle:UIAlertControllerStyleAlert];

        __weak typeof(self) weakSelf = self;
        UIAlertAction *actionConform = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [EZIoTDeviceManager deleteDevice:self.deviceInfo.deviceSerial success:^{
                    
                [weakSelf.view makeToast:@"删除成功"  duration:3.0 position:CSToastPositionCenter];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                });
                
                
            } failure:^(NSError * _Nonnull error) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
            }];
        }];
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:actionCancel];
        [alertVC addAction:actionConform];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
    else{
        [self.view makeToast:@"需要家庭主人操作"  duration:3.0 position:CSToastPositionCenter];
    }
}


@end
