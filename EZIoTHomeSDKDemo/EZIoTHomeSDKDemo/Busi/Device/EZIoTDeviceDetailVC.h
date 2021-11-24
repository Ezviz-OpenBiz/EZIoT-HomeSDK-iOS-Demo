//
//  EZIoTDeviceDetailVC.h
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EZIoTDeviceInfo;

@interface EZIoTDeviceDetailVC : UITableViewController

@property (nonatomic, strong) EZIoTDeviceInfo *deviceInfo;

@end

NS_ASSUME_NONNULL_END
