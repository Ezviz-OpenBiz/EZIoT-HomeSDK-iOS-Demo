//
//  EZIoTRoomMgrVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/19.
//

#import "EZIoTRoomMgrVC.h"
#import <EZIoTFamilySDK/EZIoTFamilySDK.h>
#import <EZIoTDeviceSDK/EZIoTDeviceSDK.h>
#import <EZIoTUserSDK/EZIoTUserInfo.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>


static NSString *reuseIdentifier = @"EZIoTRoomMgrCell";

@interface EZIoTRoomMgrVC ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBtn;

@property(nonatomic,strong) NSMutableArray<EZIoTDeviceInfo *> *selectedDevices;
@property(nonatomic,strong) NSMutableArray<EZIoTDeviceInfo *> *allDevices;
@end

@implementation EZIoTRoomMgrVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //默认房间分组下本身含有当前家庭下所有设备，无需保存
    if ([[EZIoTUserInfo getInstance].curGroupId isEqualToString:[EZIoTUserInfo getInstance].defaultGroupId] || ![EZIoTUserInfo getInstance].isCurFamilyOwn) {
        self.saveBtn.enabled = NO;
    }
    
    self.selectedDevices = [NSMutableArray arrayWithArray:[EZIoTDeviceManager getLocalDevicesWithFamilyId:[EZIoTUserInfo getInstance].curFamilyId groupId:[EZIoTUserInfo getInstance].curGroupId]];
    self.allDevices = [NSMutableArray arrayWithArray:[EZIoTDeviceManager getLocalDevicesWithFamilyId:[EZIoTUserInfo getInstance].curFamilyId]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (IBAction)clickSaveBtn:(id)sender {
    
    if (self.selectedDevices.count == 0) {
        [self.view makeToast:@"请添加设备"  duration:3.0 position:CSToastPositionCenter];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    NSMutableArray <EZIoTGroupDeviceInfo*> *groupDevices = [NSMutableArray array];
    [self.selectedDevices enumerateObjectsUsingBlock:^(EZIoTDeviceInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        obj.resourceInfos.firstObject.groupId = [EZIoTUserInfo getInstance].curGroupId;
        
        EZIoTGroupDeviceInfo *groupDevice = [EZIoTGroupDeviceInfo new];
        groupDevice.deviceSerial = obj.deviceSerial;
        groupDevice.familyId = [EZIoTUserInfo getInstance].curFamilyId;
        groupDevice.groupId = [EZIoTUserInfo getInstance].curGroupId;
        [groupDevices addObject:groupDevice];
    }];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTGroupManager groupDevicesOperationWithGroupId:[EZIoTUserInfo getInstance].curGroupId devices:groupDevices success:^{

        //update DB
        [EZIoTDeviceManager createOrUpdateDevices:self.selectedDevices familyId:[EZIoTUserInfo getInstance].curFamilyId];
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [self.view makeToast:@"保存成功"  duration:3.0 position:CSToastPositionCenter];
        NSLog(@"保存成功");

    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"error: %@", error);
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([EZIoTUserInfo getInstance].isCurFamilyOwn) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    return self.allDevices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [self setupCell:cell indexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        if ([EZIoTUserInfo getInstance].isCurFamilyOwn) {
            [self performSegueWithIdentifier:@"ShowModifyRoomVC" sender:nil];
        }
    }
    else
    {
        EZIoTDeviceInfo *deviceInfo = self.allDevices[indexPath.row];
        if ([self.selectedDevices containsObject:deviceInfo])
        {
            [self.selectedDevices removeObject:deviceInfo];
        }
        else
        {
            [self.selectedDevices addObject:deviceInfo];
        }
        [self.tableView reloadData];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"可添加至房间的设备";
    }
    return nil;
}

#pragma mark - Private

- (void)setupCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        cell.textLabel.text = [EZIoTUserInfo getInstance].curGroupName;
        if ([EZIoTUserInfo getInstance].isCurFamilyOwn) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else if (indexPath.section == 1)
    {
        EZIoTDeviceInfo *deviceInfo = self.allDevices[indexPath.row];
        cell.textLabel.text = deviceInfo.name;
        
        if ([[EZIoTUserInfo getInstance].curGroupId isEqualToString:[EZIoTUserInfo getInstance].defaultGroupId])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            if ([self.selectedDevices containsObject:deviceInfo])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
}


@end
