//
//  EZIoTDebugVC.m
//  EZIoTHomeSDKDemo
//
//  Created by yuqian on 2022/3/2.
//

#import "EZIoTDebugVC.h"
#import <EZIoTBaseSDK/EZIoTBaseSDK.h>


@interface EZIoTDebugVC ()

@property (weak, nonatomic) IBOutlet UITextField *urlInput;
@property (weak, nonatomic) IBOutlet UITextField *appIdInput;

@end

@implementation EZIoTDebugVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)clickSaveBtn:(id)sender {
    
//    self.urlInput.text = @"test15.ys7.com";
//    self.appIdInput.text = @"773891c2e33e4a7aba8935e4be8da8aa";
    
    EZIoTBaseConfigParam *configParam = [EZIoTBaseConfigParam new];
    configParam.appId = self.appIdInput.text;
    configParam.httpsUrl = self.urlInput.text;
    [EZIoTBaseGlobalSetting initSDKWithConfigParam:configParam];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

@end
