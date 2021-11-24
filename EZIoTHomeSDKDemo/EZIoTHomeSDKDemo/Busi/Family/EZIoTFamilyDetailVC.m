//
//  EZIoTFamilyDetailVC.m
//  EZIoTSmartSDKDemo
//
//  Created by PiZ on 2021/10/1.
//

#import "EZIoTFamilyDetailVC.h"
#import <EZIoTFamilySDK/EZIoTFamilySDK.h>
#import <EZIoTUserSDK/EZIoTUserInfo.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>
#import "EZIoTSingleInputVC.h"
#import "EZIoTFamilyMemberInfoVC.h"


static NSString *reusedCellId = @"EZIoTFamilyDetailVC";

@interface EZIoTFamilyDetailVC ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *quitBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addMemberBtn;

@property(nonatomic,strong) NSMutableArray <EZIoTFamilyMemberInfo *> *members;
@property (nonatomic, strong) EZIoTFamilyDetailInfo *familyDetailInfo;

@end

@implementation EZIoTFamilyDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchDataFromNetwork];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.familyDetailInfo && ![self.familyDetailInfo.familyName isEqualToString:[EZIoTUserInfo getInstance].curFamilyName]) {
        self.familyDetailInfo.familyName = [EZIoTUserInfo getInstance].curFamilyName;
        [self.tableView reloadData];
    }
}

- (void) fetchDataFromNetwork
{
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTFamilyManager getFamilyDetailInfoWithFamilyId:[EZIoTUserInfo getInstance].curFamilyId success:^(EZIoTFamilyDetailInfo * _Nonnull familyDetailInfo) {
        
        weakSelf.quitBtn.title = familyDetailInfo.isOwn ? @"删除家庭" : @"退出家庭";
        weakSelf.addMemberBtn.enabled = familyDetailInfo.isOwn;
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"familyInfoResp: %@", familyDetailInfo);
        
        weakSelf.familyDetailInfo = familyDetailInfo;
        weakSelf.members = [NSMutableArray arrayWithArray:familyDetailInfo.members];
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"error: %@", error);
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

- (IBAction)clickAddMemberBtn:(id)sender {
    
    [self performSegueWithIdentifier:@"ShowInputVC" sender:@"AddMember"];
}

- (IBAction)clickQuitBtn:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (self.familyDetailInfo.isOwn)
    {
        [EZIoTFamilyManager deleteFamilyWithFamilyId:[EZIoTUserInfo getInstance].curFamilyId success:^{
            
            [weakSelf.view makeToast:@"删除成功"  duration:3.0 position:CSToastPositionCenter];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
            
        } failure:^(NSError * _Nonnull error) {
            
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
        }];
    }
    else
    {
        [EZIoTFamilyManager memberSignoutWithFamilyId:[EZIoTUserInfo getInstance].curFamilyId success:^{
            
            [weakSelf.view makeToast:@"退出成功"  duration:3.0 position:CSToastPositionCenter];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
            
        } failure:^(NSError * _Nonnull error) {
            
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[EZIoTSingleInputVC class]]) {
        EZIoTSingleInputVC *vc = segue.destinationViewController;
        vc.type = sender;
    }
    else{
        EZIoTFamilyMemberInfoVC *vc = segue.destinationViewController;
        vc.memberInfo = sender;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 2;
    }
    
    return self.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellId forIndexPath:indexPath];
    
    [self setupCell:cell indexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0 && self.familyDetailInfo.isOwn) {
        [self performSegueWithIdentifier:@"ShowInputVC" sender:@"ModifyFamilyName"];
    }
    else if(indexPath.section == 1 && indexPath.row > 0 && self.familyDetailInfo.isOwn)
    {
        [self performSegueWithIdentifier:@"ShowMemberVC" sender:self.members[indexPath.row]];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1 && self.members.count > 0) {
        return @"家庭成员";
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.familyDetailInfo.isOwn;
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
    return @"删除成员";
}

#pragma mark - Private

- (void)setupCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"家庭名称";
            cell.detailTextLabel.text = self.familyDetailInfo.familyName;
            cell.accessoryType = self.familyDetailInfo.isOwn ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        }
        else
        {
            cell.textLabel.text = @"房间数量";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld个房间", (long)self.familyDetailInfo.roomNum];
        }
    }
    else
    {
        if (indexPath.row > 0) {
            cell.accessoryType = self.familyDetailInfo.isOwn ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        }
        EZIoTFamilyMemberInfo *memberInfo = self.members[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@(%@)", memberInfo.nick, memberInfo.contact];
        
        //需要区分创建与加入的家庭、家庭成员邀请的状态
        if ((memberInfo.type == 0 && [memberInfo.contact containsString:[EZIoTUserInfo getInstance].account]) ||
            (!self.familyDetailInfo.isOwn && memberInfo.type == 0)) {
            cell.detailTextLabel.text = @"主人";
        }
        else if (memberInfo.type == 1 && memberInfo.status == 1 && [memberInfo.contact containsString:[EZIoTUserInfo getInstance].account]) {
            cell.detailTextLabel.text = @"我";
        }
        else if(memberInfo.type == 1 && memberInfo.status == 1){
            cell.detailTextLabel.text = @"成员";
        }
        else if(memberInfo.type == 1 && memberInfo.status != 1){
            if (memberInfo.status == 0) {
                cell.detailTextLabel.text = @"待加入";
            }
            else if(memberInfo.status == 2) {
                cell.detailTextLabel.text = @"拒绝加入";
            }
            else if(memberInfo.status == 3) {
                cell.detailTextLabel.text = @"已过期";
            }
        }
    }
}

- (void) deleteSelectIndexPath:(NSIndexPath *)indexPath
{
    EZIoTFamilyMemberInfo *memberInfo = self.members[indexPath.row];
    
    if (memberInfo.type == 0 && [memberInfo.contact containsString:[EZIoTUserInfo getInstance].account]) {
        
        [self.view makeToast:@"不能删除自己" duration:3.0 position:CSToastPositionCenter];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTFamilyManager removeFamilyMemberWithFamilyId:memberInfo.familyId memberId:memberInfo.identifier success:^{
        
        NSLog(@"删除成功：%@", memberInfo.familyId);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        [weakSelf.members removeObject:memberInfo];
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"error: %@", error);
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

@end
