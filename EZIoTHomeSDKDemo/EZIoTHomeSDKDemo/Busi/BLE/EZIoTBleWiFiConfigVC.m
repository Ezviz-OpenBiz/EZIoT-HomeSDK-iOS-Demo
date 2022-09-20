//
//  EZIoTBleWiFiConfigVC.m
//  EZIoTHomeSDKDemo
//
//  Created by yuqian on 2022/3/17.
//

#import "EZIoTBleWiFiConfigVC.h"
#import <EZIoTBluetoothSDK/EZIoTBluetoothSDK.h>
#import <EZIoTNetConfigSDK/EZIoTNetConfigSDK.h>
#import <EZIoTUserSDK/EZIoTUserInfo.h>
#import <Toast/Toast.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface EZIoTBleWiFiConfigVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *ssidInput;
@property (weak, nonatomic) IBOutlet UITextField *pwdInput;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *wifiList;

@end

static NSString *cellReusedId = @"UITableViewCell";

@implementation EZIoTBleWiFiConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[EZIoTBLECenterMgr sharedInstance] getWiFiList:self.ezPeripheral.devSerial completion:^(EZIoTPeripheral * _Nullable peripheral, NSArray * _Nullable list, NSError * _Nullable error) {

        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

        if (list.count > 0) {
            weakSelf.wifiList = list;
            [weakSelf.tableView reloadData];
        }
    }];
}

- (IBAction)getStartConfig:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[EZIoTNetConfigurator sharedNetConfigurator] getConfigTokenWithFamilyId:[EZIoTUserInfo getInstance].curFamilyId groupId:[EZIoTUserInfo getInstance].curGroupId success:^(EZIoTConfigTokenInfo * _Nonnull tokenInfo) {
            

        EZIoTWiFiConfigParam *param = [EZIoTWiFiConfigParam new];
        param.ssid = self.ssidInput.text.length > 0? self.ssidInput.text :@"ezviz_test";
        param.password = self.pwdInput.text.length? self.pwdInput.text :@"test123+";
        param.lbs = tokenInfo.lbsDomain;
        param.token = tokenInfo.token;
        param.countryCode = [EZIoTUserInfo getInstance].areaInfo.code;
        param.encryptType = 5;
        
        [[EZIoTBLECenterMgr sharedInstance] wifiConfig:self.ezPeripheral.devSerial configParam:param completion:^(BOOL result, NSError * _Nullable error) {
                
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if (error) {
                [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"BLE WiFi 设置失败"  duration:3.0 position:CSToastPositionCenter];
            }
            else
            {
                [weakSelf.view makeToast:@"BLE WiFi 设置成功"  duration:3.0 position:CSToastPositionCenter];
            }
        }];
        
    } failure:^(NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.wifiList.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReusedId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellReusedId];
    }
    
    NSDictionary *dic = self.wifiList[indexPath.row];
    
    cell.textLabel.text = dic[@"ssid"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", dic[@"rssi"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.view endEditing:YES];
    
    NSDictionary *dic = self.wifiList[indexPath.row];
    self.ssidInput.text = dic[@"ssid"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
