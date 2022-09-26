//
//  EZIoTLoginHandle.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/11.
//

#import "EZIoTLoginHandle.h"
#import <EZIoTBaseSDK/EZIoTBaseSDK.h>
#import <EZIoTBaseSDK/YSDCLog.h>
#import <EZIoTBaseSDK/YSConfigInformation.h>
#import <EZIoTUserSDK/EZIoTUserSDK.h>
#import <EZIoTUserSDK/EZIoTLoginConfigTool.h>
#import <EZIoTNetConfigSDK/EZIoTNetConfigSDK.h>
#import <EZIoTIPCSDK/EZIoTIPCGlobalSetting.h>

@implementation EZIoTLoginHandle

+ (void) loginSuccessHandle
{
    [EZIoTLoginConfigTool startRequestSystemConfiguration:^{
        NSLog(@"");
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"");
    }];
    
    [EZIoTIPCGlobalSetting registerOnLoginSuccess];
    
    [YSDCLog setUserSessionBlock:^NSString *{
        return [EZIoTUserInfo getInstance].sessionId?:@"";
    } userIdBlock:^NSString *{
        return [EZIoTUserInfo getInstance].userId?:@"";
        
    } logServerBlock:^NSString *{
        return [YSConfigInformation getDCLogAddress];
        
    } systemNamePrefixBlock:^NSString *{
        return @"iot_";
    } appIdBlock:^NSString *{
        return [EZIoTNetworkingSetting sharedInstance].appId ?:@"";
    } appPublicVer:@"1.0.0"];
    
    [YSDCLog observeAppLife];
}


@end
