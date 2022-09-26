//
//  EZIoTMineVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/9/29.
//

#import "EZIoTMineVC.h"
#import <EZIoTUserSDK/EZIoTUserSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <EZIoTIPCSDK/EZIoTIPCGlobalSetting.h>


static NSString *TableReusedID = @"mineCell";

@interface EZIoTMineVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@end

@implementation EZIoTMineVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.nicknameLabel.text = [EZIoTUserInfo getInstance].nickname?:@"welcome";
    [self fetchData];
}

- (void) fetchData
{
    __weak typeof(self) weakSelf = self;
    [EZIoTUserInfoManager getUserProfileWithSuccess:^(EZIoTUserProfileInfo * _Nonnull profileInfo) {
        [weakSelf.tableView reloadData];
        [weakSelf fetchAvatar];
        
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常" duration:3.0 position:CSToastPositionCenter];
    }];
}

- (void) fetchAvatar
{
    if ([EZIoTUserInfo getInstance].avatarPath) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[EZIoTUserInfo getInstance].avatarPath]];
            });
        });
    }
}

- (void) logout
{
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTUserAccountManager logoutWithSuccess:^{
            
        [EZIoTIPCGlobalSetting registerOnLogout];
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [[EZIoTUserInfo getInstance] clearForLoginOut];
        UIViewController *vc = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController;
        
        UIWindow* window = nil;
        if (@available(iOS 13.0, *))
        {
            for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes)
            {
                if (windowScene.activationState == UISceneActivationStateForegroundActive)
                {
                    window = windowScene.windows.firstObject;
                    break;
                }
            }
        }else{
            window = [UIApplication sharedApplication].keyWindow;
        }
        
        window.rootViewController = vc;
        [window makeKeyAndVisible];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常" duration:3.0 position:CSToastPositionCenter];
    }];
}

- (IBAction)clickLogoutBtn:(id)sender {
    
    [self logout];
}

@end
