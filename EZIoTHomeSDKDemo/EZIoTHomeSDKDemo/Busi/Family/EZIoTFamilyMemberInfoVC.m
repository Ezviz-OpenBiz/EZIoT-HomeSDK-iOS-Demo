//
//  EZIoTFamilyMemberInfoVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/27.
//

#import "EZIoTFamilyMemberInfoVC.h"
#import <EZIoTFamilySDK/EZIoTFamilySDK.h>
#import <EZIoTUserSDK/EZIoTUserInfo.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>
#import "EZIoTSingleInputVC.h"

@interface EZIoTFamilyMemberInfoVC ()

@property (weak, nonatomic) IBOutlet UILabel *memberNickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;
@property (weak, nonatomic) IBOutlet UILabel *inviteStatusLabel;

@end

@implementation EZIoTFamilyMemberInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.memberNickNameLabel.text = self.memberInfo.nick.length > 0 ? self.memberInfo.nick :@"none" ;
    self.contactLabel.text = self.memberInfo.contact;
    
    if (self.memberInfo.status == 0) {
        self.inviteStatusLabel.text = @"待加入";
    }
    else if(self.memberInfo.status == 1) {
        self.inviteStatusLabel.text = @"已加入";
    }
    else if(self.memberInfo.status == 2) {
        self.inviteStatusLabel.text = @"拒绝加入";
    }
    else if(self.memberInfo.status == 3) {
        self.inviteStatusLabel.text = @"已过期";
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    EZIoTSingleInputVC *vc = segue.destinationViewController;
    vc.type = sender;
    vc.memberInfo = self.memberInfo;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(self.memberInfo.status == 1) {
        [self performSegueWithIdentifier:@"ShowInputVC" sender:@"ModifyMemberName"];
    }
}

@end
