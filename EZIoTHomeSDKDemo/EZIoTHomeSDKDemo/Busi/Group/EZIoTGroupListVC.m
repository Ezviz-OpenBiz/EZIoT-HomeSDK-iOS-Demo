//
//  EZIoTGroupListVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/18.
//

#import "EZIoTGroupListVC.h"
#import <EZIoTFamilySDK/EZIoTFamilySDK.h>
#import <EZIoTDeviceSDK/EZIoTDeviceSDK.h>
#import <EZIoTUserSDK/EZIoTUserInfo.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>

static NSString *reusedCellId = @"EZIoTGroupListCell";

@interface EZIoTGroupListVC ()

@property(nonatomic,strong) NSMutableArray <EZIoTGroupInfo *> *groupInfos;

@end

@implementation EZIoTGroupListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchDataFromNetwork];
}

- (void) fetchDataFromNetwork
{
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTGroupManager getGroupListWithFamilyId:[EZIoTUserInfo getInstance].curFamilyId success:^(NSArray<EZIoTGroupInfo *> * _Nonnull groupInfos) {
        
        NSLog(@"groupInfos: %@", groupInfos);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        weakSelf.groupInfos = [NSMutableArray arrayWithArray:groupInfos];;
        [weakSelf.tableView reloadData];
        
        if ([EZIoTUserInfo getInstance].defaultGroupId.length == 0)
        {
            for (EZIoTGroupInfo *groupInfo in groupInfos)
            {
                if (groupInfo.isDefaultGroup)
                {
                    [EZIoTUserInfo getInstance].defaultGroupId = groupInfo.groupId;
                    [EZIoTUserInfo getInstance].curGroupId = groupInfo.groupId;
                    [EZIoTUserInfo getInstance].curGroupName = groupInfo.groupName;
                }
            }
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"error: %@", error);
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellId forIndexPath:indexPath];
    
    [self setupCell:cell indexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    for (UITableViewCell *cell in tableView.visibleCells) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [EZIoTUserInfo getInstance].curGroupId = self.groupInfos[indexPath.row].groupId;
    [EZIoTUserInfo getInstance].curGroupName = self.groupInfos[indexPath.row].groupName;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self deleteSelectIndexPath:indexPath];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}


#pragma mark - Private

- (void)setupCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    EZIoTGroupInfo *groupInfo = self.groupInfos[indexPath.row];

    cell.textLabel.text = groupInfo.groupName;
    
//    if (groupInfo.isDefaultGroup)
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu台设备", (unsigned long)[EZIoTDeviceManager getLocalDevicesWithFamilyId:groupInfo.familyId].count];
//    else
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu台设备", (unsigned long)[EZIoTDeviceManager getLocalDevicesWithFamilyId:groupInfo.familyId groupId:groupInfo.groupId].count];
    
    if ([EZIoTUserInfo getInstance].curGroupId == groupInfo.groupId)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void) deleteSelectIndexPath:(NSIndexPath *)indexPath
{
    EZIoTGroupInfo *groupInfo = self.groupInfos[indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    EZIoTGroupInfo *targetGroupInfo;
    for (EZIoTGroupInfo *g in self.groupInfos) {
        if (![g.groupId isEqualToString:groupInfo.groupId]) {
            targetGroupInfo = g;
            break;
        }
    }
    
    [EZIoTGroupManager deleteGroupWithFamilyId:groupInfo.familyId groupId:groupInfo.groupId targetGroupId:targetGroupInfo.groupId success:^{
           
        NSLog(@"删除成功：%@", groupInfo.groupId);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        //update current group info
        if ([EZIoTUserInfo getInstance].curGroupId == groupInfo.groupId)
        {
            [EZIoTUserInfo getInstance].curGroupId = targetGroupInfo.groupId;
            [EZIoTUserInfo getInstance].curGroupName = targetGroupInfo.groupName;
        }
        
        [weakSelf.groupInfos removeObject:groupInfo];
        
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"error: %@", error);
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

@end
