//
//  EZIoTRoomListVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/18.
//

#import "EZIoTRoomListVC.h"
#import <EZIoTFamilySDK/EZIoTFamilySDK.h>
#import <EZIoTDeviceSDK/EZIoTDeviceSDK.h>
#import <EZIoTUserSDK/EZIoTUserInfo.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>

static NSString *reusedCellId = @"EZIoTGroupListCell";

@interface EZIoTRoomListVC ()

@property(nonatomic,strong) NSMutableArray <EZIoTRoomInfo *> *roomInfos;

@end

@implementation EZIoTRoomListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchDataFromNetwork];
}

- (void) fetchDataFromNetwork
{
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTRoomManager getRoomListWithFamilyId:[EZIoTUserInfo getInstance].curFamilyId success:^(NSArray<EZIoTRoomInfo *> * _Nonnull roomInfos) {
        
        NSLog(@"groupInfos: %@", roomInfos);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        weakSelf.roomInfos = [NSMutableArray arrayWithArray:roomInfos];;
        [weakSelf.tableView reloadData];
        
        if ([EZIoTUserInfo getInstance].defaultGroupId.length == 0)
        {
            for (EZIoTRoomInfo *roomInfo in roomInfos)
            {
                if (roomInfo.isDefaultRoom)
                {
                    [EZIoTUserInfo getInstance].defaultGroupId = roomInfo.roomId;
                    [EZIoTUserInfo getInstance].curGroupId = roomInfo.roomId;
                    [EZIoTUserInfo getInstance].curGroupName = roomInfo.roomName;
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
    return self.roomInfos.count;
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
    
    [EZIoTUserInfo getInstance].curGroupId = self.roomInfos[indexPath.row].roomId;
    [EZIoTUserInfo getInstance].curGroupName = self.roomInfos[indexPath.row].roomName;
    
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
    EZIoTRoomInfo *roomInfo = self.roomInfos[indexPath.row];

    cell.textLabel.text = roomInfo.roomName;
    
//    if (groupInfo.isDefaultGroup)
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu台设备", (unsigned long)[EZIoTDeviceManager getLocalDevicesWithFamilyId:groupInfo.familyId].count];
//    else
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu台设备", (unsigned long)[EZIoTDeviceManager getLocalDevicesWithFamilyId:groupInfo.familyId groupId:groupInfo.groupId].count];
    
    if ([EZIoTUserInfo getInstance].curGroupId == roomInfo.roomId)
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
    EZIoTRoomInfo *roomInfo = self.roomInfos[indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    EZIoTRoomInfo *targetRoomInfo;
    for (EZIoTRoomInfo *g in self.roomInfos) {
        if (![g.roomId isEqualToString:roomInfo.roomId]) {
            targetRoomInfo = g;
            break;
        }
    }
    
    [EZIoTRoomManager deleteRoomWithFamilyId:roomInfo.familyId roomId:roomInfo.roomId targetRoomId:targetRoomInfo.roomId success:^{
           
        NSLog(@"删除成功：%@", roomInfo.roomId);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        //update current group info
        if ([EZIoTUserInfo getInstance].curGroupId == roomInfo.roomId)
        {
            [EZIoTUserInfo getInstance].curGroupId = targetRoomInfo.roomId;
            [EZIoTUserInfo getInstance].curGroupName = targetRoomInfo.roomName;
        }
        
        [weakSelf.roomInfos removeObject:roomInfo];
        
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"error: %@", error);
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

@end
