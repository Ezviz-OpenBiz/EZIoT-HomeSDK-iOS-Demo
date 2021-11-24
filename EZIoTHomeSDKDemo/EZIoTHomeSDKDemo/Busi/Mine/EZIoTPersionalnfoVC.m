//
//  EZIoTPersionalnfoVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/9/30.
//

#import "EZIoTPersionalnfoVC.h"
#import <EZIoTUserSDK/EZIoTUserSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>
#import "EZIoTSingleInputVC.h"
#import "EZIoTModifyContactVC.h"


@interface EZIoTPersionalnfoVC ()

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;

@end

@implementation EZIoTPersionalnfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.userNameLabel.text = [EZIoTUserInfo getInstance].userName?:@"none";
    self.nickLabel.text = [EZIoTUserInfo getInstance].nickname?:@"去设置";
    self.phoneLabel.text = [EZIoTUserInfo getInstance].phone>0?[EZIoTUserInfo getInstance].phone:@"去设置";
    self.emailLabel.text = [EZIoTUserInfo getInstance].email.length>0?[EZIoTUserInfo getInstance].email:@"去设置";
    self.genderLabel.text = [EZIoTUserInfo getInstance].gender==1?@"男":@"女";
    self.birthLabel.text = [EZIoTUserInfo getInstance].birth.length>0?[EZIoTUserInfo getInstance].birth:@"去设置";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        return;
    }
    else if (indexPath.row == 1 || indexPath.row == 4)
    {
        EZIoTSingleInputVC *vc = [[UIStoryboard storyboardWithName:@"Family" bundle:nil]instantiateViewControllerWithIdentifier:@"EZIoTSingleInputVC"];
        switch (indexPath.row) {
            case 1:
                vc.type = @"ModifyNickname";
                break;
            case 4:
                vc.type = @"ModifyBirth";
                break;
            default:
                break;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 2 || indexPath.row == 3)
    {
        //pvp 修改旧手机号，通过新手机号验证
        //pve 修改旧手机号，通过新邮箱验证
        //eve 修改旧邮箱，通过新邮箱验证
        //evp 修改旧邮箱，通过新手机号验证
        if ([EZIoTUserInfo getInstance].phone.length > 0 && [EZIoTUserInfo getInstance].email.length > 0 )
        {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"验证身份" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            __weak typeof(self) weakSelf = self;
            UIAlertAction *actionPhone = [UIAlertAction actionWithTitle:@"短信验证" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [weakSelf performSegueWithIdentifier:@"ShowModifyContactVC" sender:indexPath.row == 2 ? @"pvp" : @"evp"];
            }];
            UIAlertAction *actionEmail = [UIAlertAction actionWithTitle:@"邮箱验证" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf performSegueWithIdentifier:@"ShowModifyContactVC" sender:indexPath.row == 2 ? @"pve" : @"eve"];
            }];
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertVC addAction:actionPhone];
            [alertVC addAction:actionEmail];
            [alertVC addAction:actionCancel];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
        else if ([EZIoTUserInfo getInstance].phone.length == 0 && [EZIoTUserInfo getInstance].email.length > 0 )
        {
            [self performSegueWithIdentifier:@"ShowModifyContactVC" sender:indexPath.row == 2 ? @"pve" : @"eve"];
        }
        else if ([EZIoTUserInfo getInstance].phone.length > 0 && [EZIoTUserInfo getInstance].email.length == 0 )
        {
            [self performSegueWithIdentifier:@"ShowModifyContactVC" sender:indexPath.row == 2 ? @"pvp" : @"evp"];
        }
    }
    else if (indexPath.row == 5)
    {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择性别" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        __weak typeof(self) weakSelf = self;
        UIAlertAction *actionMale = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [EZIoTUserInfoManager modifyUserGender:1 success:^{
                [weakSelf.view endEditing:YES];
                weakSelf.genderLabel.text = [EZIoTUserInfo getInstance].gender==1?@"男":@"女";
                [weakSelf.navigationController.view makeToast:@"修改成功"  duration:2.0 position:CSToastPositionCenter];
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
            } failure:^(NSError * _Nonnull error) {
                
                [weakSelf.view endEditing:YES];
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
            }];
        }];
        UIAlertAction *actionFemale = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [EZIoTUserInfoManager modifyUserGender:2 success:^{
                [weakSelf.view endEditing:YES];
                weakSelf.genderLabel.text = [EZIoTUserInfo getInstance].gender==1?@"男":@"女";
                [weakSelf.navigationController.view makeToast:@"修改成功"  duration:2.0 position:CSToastPositionCenter];
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            } failure:^(NSError * _Nonnull error) {
                
                [weakSelf.view endEditing:YES];
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
            }];
        }];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:actionMale];
        [alertVC addAction:actionFemale];
        [alertVC addAction:actionCancel];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    EZIoTModifyContactVC *vc = segue.destinationViewController;
    vc.type = sender;
}

@end
