//
//  EZIoTFamilyListVC.m
//  EZIoTSmartSDKDemo
//
//  Created by PiZ on 2021/10/1.
//

#import "EZIoTFamilyListVC.h"
#import <EZIoTFamilySDK/EZIoTFamilySDK.h>
#import <EZIoTUserSDK/EZIoTUserInfo.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>

static NSString *reusedCellId = @"EZIoTFamilyListVC";

@interface EZIoTFamilyListVC ()

@property(nonatomic,strong) NSMutableArray <EZIoTFamilyInfo *> *joinFamilyInfos;
@property(nonatomic,strong) NSMutableArray <EZIoTFamilyInfo *> *ownFamilyInfos;

@end

@implementation EZIoTFamilyListVC

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self fetchDataFromNetwork];
}

- (void) fetchDataFromNetwork
{
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTFamilyManager getExtFamilyListWithSuccess:^(EZIoTFamilyInfoResp * _Nonnull familyInfoResp) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"familyInfoResp: %@", familyInfoResp);
        weakSelf.joinFamilyInfos = [NSMutableArray arrayWithArray:familyInfoResp.joinFamilyInfos];
        weakSelf.ownFamilyInfos = [NSMutableArray arrayWithArray:familyInfoResp.ownFamilyInfos];
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"error: %@", error);
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return self.ownFamilyInfos.count;
    }
    return self.joinFamilyInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellId forIndexPath:indexPath];
    
    [self setupCell:cell indexPath:indexPath];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"创建的家庭";
    }
    return @"加入的家庭";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    for (UITableViewCell *cell in tableView.visibleCells) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (indexPath.section == 0) {
        [EZIoTUserInfo getInstance].curFamilyId = self.ownFamilyInfos[indexPath.row].familyId;
        [EZIoTUserInfo getInstance].curFamilyName = self.ownFamilyInfos[indexPath.row].familyName;
        [EZIoTUserInfo getInstance].isCurFamilyOwn = YES;
    }
    else{
        [EZIoTUserInfo getInstance].curFamilyId = self.joinFamilyInfos[indexPath.row].familyId;
        [EZIoTUserInfo getInstance].curFamilyName = self.joinFamilyInfos[indexPath.row].familyName;
        [EZIoTUserInfo getInstance].isCurFamilyOwn = NO;
    }
    [EZIoTUserInfo getInstance].curGroupId = @"";
    [EZIoTUserInfo getInstance].curGroupName = @"";
    
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
    EZIoTFamilyInfo *familyInfo;
    if (indexPath.section == 0)
    {
        familyInfo = self.ownFamilyInfos[indexPath.row];
    }
    else
    {
        familyInfo = self.joinFamilyInfos[indexPath.row];
    }
    cell.textLabel.text = familyInfo.familyName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld个房间, %ld个设备", (long)familyInfo.roomNum, (long)familyInfo.deviceNum];
    
    if ([EZIoTUserInfo getInstance].curFamilyId == familyInfo.familyId)
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
    EZIoTFamilyInfo *familyInfo;
    if (indexPath.section == 0)
    {
        familyInfo = self.ownFamilyInfos[indexPath.row];
    }
    else
    {
        familyInfo = self.joinFamilyInfos[indexPath.row];
    }
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTFamilyManager deleteFamilyWithFamilyId:familyInfo.familyId success:^{
        
        NSLog(@"删除成功：%@", familyInfo.familyId);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        //clear cache info
        if ([EZIoTUserInfo getInstance].curFamilyId == familyInfo.familyId)
        {
            [EZIoTUserInfo getInstance].curFamilyId = nil;
            [EZIoTUserInfo getInstance].curFamilyName = nil;
        }
        
        indexPath.section == 0 ? [weakSelf.ownFamilyInfos removeObject:familyInfo] : [weakSelf.joinFamilyInfos removeObject:familyInfo];
        
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"error: %@", error);
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

@end
