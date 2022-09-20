//
//  AppDelegate.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/6/7.
//

#import "AppDelegate.h"
#import <EZIoTBaseSDK/EZIoTBaseSDK.h>
#import <EZIoTBaseSDK/NSData+FastHex.h>
#import <EZIoTUserSDK/EZIoTUserSDK.h>
#import <EZIoTDebugSDK/EZIoTDebugSDK.h>
#import <EZIoTRouter/EZIoTRouter.h>
#import <EZIoTIPCSDK/EZIoTIPCGlobalSetting.h>
#import <Toast/Toast.h>
#import "EZIoTLoginHandle.h"
#import <EZIoTBluetoothSDK/EZIoTDevControlManager.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {   
    
#warning 初始化SDK, 请输入您的AppId
    [self setupAppSDK:@"377f3df63b2e41bf8625d955f0acd3ae"];
    
    if (@available(iOS 13.0, *)) {
      
    } else {
      
        if ([EZIoTUserInfo getInstance].isLogined)
        {
            if ([EZIoTUserInfo getInstance].isAutoLogin)
            {
                UIViewController *vc = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"EZIoTMainTabVC"];
                self.window.rootViewController = vc;
                [self.window makeKeyAndVisible];
                
                [EZIoTLoginHandle loginSuccessHandle];
            }
            else
            {
                __weak typeof(self) weakSelf = self;
                [EZIoTUserAccountManager refreshSessionWithSuccess:^{
                                
                    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"EZIoTMainTabVC"];
                    weakSelf.window.rootViewController = vc;
                    [weakSelf.window makeKeyAndVisible];
                    
                    [EZIoTLoginHandle loginSuccessHandle];
                    
                } failure:^(NSError * _Nonnull error) {
                    UIViewController *vc = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController;
                    weakSelf.window.rootViewController = vc;
                    [weakSelf.window makeKeyAndVisible];
                }];
            }
        }
        else
        {
            UIViewController *vc = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController;
            self.window.rootViewController = vc;
            [self.window makeKeyAndVisible];
        }
    }
    
    //注册通知：session刷新异常（当用户session发生异常时，UserSDK内部会进行刷新session操作，如果刷新失败则会发送通知 HTTP_RESPONSE_REFRESH_SESSION_ERROR ）
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionError:)
                                                 name:@"HTTP_RESPONSE_REFRESH_SESSION_ERROR"
                                               object:nil];
    
    return YES;
}

- (void) setupAppSDK:(NSString *)appId
{
    [EZIoTRouter setupRouter];
    
    EZIoTBaseConfigParam *configParam = [EZIoTBaseConfigParam new];
    configParam.appId = appId;
//    configParam.httpsUrl = @"test12.ys7.com";
    [EZIoTBaseGlobalSetting initSDKWithConfigParam:configParam];
    
    [EZIoTUserGlobalSetting initSDK];
    
    [EZIoTIPCGlobalSetting initSDK];
    
    [YSLogDefine setLogMode:EZIoTLogModeFileAndLog];
}

- (void)sessionError:(NSNotification *)notification
{
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
    
    UIViewController *vc = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController;
    window.rootViewController = vc;
    [window makeKeyAndVisible];
    
    [window.rootViewController.view makeToast:@"Session异常，请重新登录"  duration:2.0 position:CSToastPositionCenter];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [EZIoTIPCGlobalSetting registerOnEnterBackground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [EZIoTIPCGlobalSetting registerOnEnterForeground];
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
