//
//  EZIoTHomePageVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/9/30.
//

#import "EZIoTHomePageVC.h"
#import <EZIoTFamilySDK/EZIoTFamilySDK.h>
#import <EZIoTUserSDK/EZIoTUserInfo.h>
#import <Toast/Toast.h>


@interface EZIoTHomePageVC ()

@property (weak, nonatomic) IBOutlet UILabel *curFamilyLabel;
@property (weak, nonatomic) IBOutlet UILabel *curRoomLabel;

@end

@implementation EZIoTHomePageVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.curFamilyLabel.text = [EZIoTUserInfo getInstance].curFamilyName.length > 0 ? [EZIoTUserInfo getInstance].curFamilyName : @"未选择";
    self.curRoomLabel.text = [EZIoTUserInfo getInstance].curGroupName.length > 0 ? [EZIoTUserInfo getInstance].curGroupName : @"未选择";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0) {

        if ([EZIoTUserInfo getInstance].curFamilyId.length > 0) {
            [self performSegueWithIdentifier:@"ShowFamilyDetailVC" sender:nil];
        }
        else{
            [self.view makeToast:@"请先选择家庭"  duration:3.0 position:CSToastPositionCenter];
        }
    }
    else if (indexPath.section == 1 && indexPath.row == 0) {

        if ([EZIoTUserInfo getInstance].curGroupId.length > 0) {
            [self performSegueWithIdentifier:@"ShowRoomMgrVC" sender:nil];
        }
        else{
            [self.view makeToast:@"请先选择房间"  duration:3.0 position:CSToastPositionCenter];
        }
    }
    else if (indexPath.section == 1 && indexPath.row == 1) {

        if ([EZIoTUserInfo getInstance].curFamilyId.length > 0) {
            [self performSegueWithIdentifier:@"ShowGroupListVC" sender:nil];
        }
        else{
            [self.view makeToast:@"请先选择家庭"  duration:3.0 position:CSToastPositionCenter];
        }
    }
    else if (indexPath.section == 1 && indexPath.row == 2) {

        if ([EZIoTUserInfo getInstance].curFamilyId.length > 0) {
            [self performSegueWithIdentifier:@"ShowCreateRoomVC" sender:nil];
        }
        else{
            [self.view makeToast:@"请先选择家庭"  duration:3.0 position:CSToastPositionCenter];
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 0) {

        if ([EZIoTUserInfo getInstance].curFamilyId.length > 0 && [EZIoTUserInfo getInstance].curGroupId.length > 0) {
            [self performSegueWithIdentifier:@"ShowDeviceListVC" sender:nil];
        }
        else{
            [self.view makeToast:@"请先选择家庭和房间"  duration:3.0 position:CSToastPositionCenter];
        }
    }
}

- (IBAction)ClickAddDeviceBtn:(id)sender {
    
    if ([EZIoTUserInfo getInstance].curFamilyId.length > 0 && [EZIoTUserInfo getInstance].curGroupId.length > 0) {
        [self performSegueWithIdentifier:@"ShowAddDeviceVC" sender:nil];
    }
    else{
        [self.view makeToast:@"请先选择家庭和房间"  duration:3.0 position:CSToastPositionCenter];
    }
}
@end
