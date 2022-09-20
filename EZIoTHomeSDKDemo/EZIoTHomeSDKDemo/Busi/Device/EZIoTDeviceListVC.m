//
//  EZIoTDeviceListVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/22.
//

#import "EZIoTDeviceListVC.h"
#import <Toast/Toast.h>
#import <EZIoTUserSDK/EZIoTUserInfo.h>
#import <EZIoTDeviceSDK/EZIoTDeviceSDK.h>
#import <MJRefresh/MJRefresh.h>
#import "EZIoTDeviceDetailVC.h"
//#import <EZIoTIPCSDK/EZIoTIPCGlobalSetting.h>
#import "EZIoTIPCGlobalSetting.h"

#define Device_Request_Limit  10

static NSString *reuseIdentifier = @"EZIoTDeviceListCell";

@interface EZIoTDeviceListVC ()

@property(nonatomic,strong) NSMutableArray<EZIoTDeviceInfo *> *devicesList;
@property(nonatomic,strong) EZIoTDeviceInfoResp * deviceInfoResp;
@property(nonatomic,assign) NSUInteger currentPage;

@end

@implementation EZIoTDeviceListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([_type isEqualToString:@"db"]) {
     
        if ([[EZIoTUserInfo getInstance].curGroupId isEqualToString:[EZIoTUserInfo getInstance].defaultGroupId])
        {
            self.devicesList = [NSMutableArray arrayWithArray:[EZIoTDeviceManager getLocalDevicesWithFamilyId:[EZIoTUserInfo getInstance].curFamilyId]];
        }
        else
        {
            self.devicesList = [NSMutableArray arrayWithArray:[EZIoTDeviceManager getLocalDevicesWithFamilyId:[EZIoTUserInfo getInstance].curFamilyId groupId:[EZIoTUserInfo getInstance].curGroupId]];
        }
        
    }
    else
    {
        __weak typeof(self) weakSelf = self;
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf requestDatas:YES];
        }];
        
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            
            if (!self.deviceInfoResp.hasNext) {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                return;
            }
            [weakSelf requestDatas:NO];
        }];
        
        [self.tableView.mj_header beginRefreshing];
    }
}

- (void) requestDatas:(BOOL)isRefresh
{
    __weak typeof(self) weakSelf = self;
    NSInteger offset = isRefresh ? 0 : self.currentPage * Device_Request_Limit;
    [EZIoTDeviceManager getDeviceListWithFamilyId:[EZIoTUserInfo getInstance].curFamilyId groupId:[EZIoTUserInfo getInstance].curGroupId offset:offset limit:Device_Request_Limit success:^(EZIoTDeviceInfoResp * _Nonnull deviceInfoResp) {
        
        if (isRefresh) {
            weakSelf.devicesList = [NSMutableArray arrayWithArray:deviceInfoResp.devices];
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer resetNoMoreData];
            weakSelf.tableView.mj_header.hidden = YES;
            weakSelf.currentPage = 0;
            
            if (!deviceInfoResp || deviceInfoResp.devices.count == 0) {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                return;
            }
        }
        else
        {
            [weakSelf.devicesList addObjectsFromArray:deviceInfoResp.devices];
            [weakSelf.tableView.mj_footer endRefreshing];
            ++weakSelf.currentPage;
        }
        
        if (!deviceInfoResp.hasNext) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        
        [EZIoTIPCGlobalSetting registerOnDevicesInsertOrUpdate:weakSelf.devicesList];
        
        weakSelf.deviceInfoResp = deviceInfoResp;
        NSLog(@"deviceInfoResp.devices: %@", deviceInfoResp.devices);
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        isRefresh ? [weakSelf.tableView.mj_header endRefreshing] : [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    EZIoTDeviceDetailVC *vc = segue.destinationViewController;
    vc.deviceInfo = sender;
    NSLog(@"%@", vc.deviceInfo.propFeatureItems);
    NSLog(@"%@", vc.deviceInfo.actionFeatureItems);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.prefersLargeTitles = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.prefersLargeTitles = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devicesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    EZIoTDeviceInfo *deviceInfo = self.devicesList[indexPath.row];
    cell.textLabel.text = deviceInfo.name;
    cell.detailTextLabel.text = deviceInfo.status != 1 ? @"离线" : nil;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier: @"ShowDeviceDetail" sender:self.devicesList[indexPath.row]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    CGPoint point=scrollView.contentOffset;
    if (point.y < -150) {
        self.tableView.mj_header.hidden = NO;
    }
}

@end
