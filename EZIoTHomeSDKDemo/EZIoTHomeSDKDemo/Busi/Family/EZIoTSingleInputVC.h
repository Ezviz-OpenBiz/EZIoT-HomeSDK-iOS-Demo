//
//  EZIoTSingleInputVC.h
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EZIoTFamilyMemberInfo,EZIoTDeviceInfo;

@interface EZIoTSingleInputVC : UITableViewController

@property (nonatomic, copy) NSString *type;

//biz
@property(nonatomic, strong) EZIoTFamilyMemberInfo *memberInfo;
@property (nonatomic, strong) EZIoTDeviceInfo *deviceInfo;

@end

NS_ASSUME_NONNULL_END
