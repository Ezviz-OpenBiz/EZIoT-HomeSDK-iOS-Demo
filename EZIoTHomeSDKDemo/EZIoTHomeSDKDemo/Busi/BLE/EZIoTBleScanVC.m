//
//  EZIoTBleScanVC.m
//  EZIoTHomeSDKDemo
//
//  Created by yuqian on 2022/3/15.
//

#import "EZIoTBleScanVC.h"
#import <EZIoTBluetoothSDK/EZIoTBluetoothSDK.h>
#import <EZIoTUserSDK/EZIoTUserInfo.h>
#import <EZIoTBaseSDK/EZIoTNetworking.h>
#import "EZIoTBleDevMainVC.h"



static NSString * ReusedCellID = @"UITableViewCell";

@interface EZIoTBleScanVC ()

@property (weak, nonatomic) IBOutlet UIButton *scanBtn;

@property (nonatomic, strong) NSMutableArray<EZIoTPeripheral *> *dataSource;
@property (nonatomic, strong) NSLock *lock;

@end

@implementation EZIoTBleScanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    EZIoTBLEInitConfigParam *param = [EZIoTBLEInitConfigParam new];
    param.appId = [EZIoTNetworkingSetting sharedInstance].appId;
    param.httpApiDomain = [EZIoTNetworkingSetting sharedInstance].httpsUrl;
    param.sessionId = [EZIoTUserInfo getInstance].sessionId;
    param.userId = [EZIoTUserInfo getInstance].userId;
    [EZIoTBluetoothGlobalSetting initSDKWithParam:param];
    [EZIoTBluetoothGlobalSetting initSDKWithParam:param paramChangeBlock:^EZIoTBLEInitConfigParam * _Nonnull{
        
        EZIoTBLEInitConfigParam *param = [EZIoTBLEInitConfigParam new];
        param.appId = [EZIoTNetworkingSetting sharedInstance].appId;
        param.httpApiDomain = [EZIoTNetworkingSetting sharedInstance].httpsUrl;
        param.sessionId = [EZIoTUserInfo getInstance].sessionId;
        param.userId = [EZIoTUserInfo getInstance].userId;
        return param;
        
    }];
    [EZIoTBluetoothGlobalSetting setLogCallBack:^(NSString * _Nonnull log) {
        NSLog(@"%@",log);
    }];
    
    
    [self.scanBtn setTitle:@"Scan" forState:UIControlStateNormal];
    [self.scanBtn setTitle:@"Stop" forState:UIControlStateSelected];
    [self.scanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.scanBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
}

- (IBAction)clickScanBtn:(UIButton *)sender
{
    self.scanBtn.selected = !self.scanBtn.selected;
    
    if (self.scanBtn.selected)
    {
        __weak typeof(self) weakSelf = self;
        
        [[EZIoTBLECenterMgr sharedInstance] scanPeripherals:NO allowDuplicate:YES filterBindDevice:NO scanBlock:^(EZIoTPeripheral * _Nullable peripheral, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
                
                [weakSelf.lock lock];
                if (peripheral && ![weakSelf isContain:peripheral])
                {
                    [weakSelf.dataSource addObject:peripheral];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.tableView reloadData];
                    });
                }
                [weakSelf.lock unlock];
            });
        }];
    }
    else
    {
        [[EZIoTBLECenterMgr sharedInstance] stopScan];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [[EZIoTBLECenterMgr sharedInstance] stopScan];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReusedCellID forIndexPath:indexPath];
    
    EZIoTPeripheral *per = self.dataSource[indexPath.row];
    
    cell.textLabel.text = per.devName?:@"unknown";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", per.RSSI];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc]init];
}
    
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Scan result:";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier: @"ShowBleDeviceDetail" sender:self.dataSource[indexPath.row]];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    EZIoTBleDevMainVC *vc = segue.destinationViewController;
    vc.ezPeripheral = sender;
}

- (NSArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:5];
    }
    return _dataSource;
}

- (NSLock *)lock
{
    if (!_lock) {
        _lock = [[NSLock alloc]init];
    }
    return _lock;
}

- (BOOL)isContain:(EZIoTPeripheral *)peripheral
{
    for (EZIoTPeripheral * p in self.dataSource)
    {
        if ([peripheral.peripheral.identifier.UUIDString isEqualToString:p.peripheral.identifier.UUIDString]) {
            return YES;
        }
    }
    return NO;
}

@end
