//
//  SceneDelegate.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/6/7.
//

#import "SceneDelegate.h"
#import <EZIoTUserSDK/EZIoTUserSDK.h>
#import "EZIoTLoginHandle.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    
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


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}


@end
