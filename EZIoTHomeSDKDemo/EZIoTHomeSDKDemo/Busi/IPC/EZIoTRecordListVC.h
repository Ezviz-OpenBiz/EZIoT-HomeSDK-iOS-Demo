//
//  EZIoTRecordListVC.h
//  EZIoTHomeSDKDemo
//
//  Created by yuqian on 2021/12/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EZIoTDeviceInfo;

@interface EZIoTRecordListVC : UIViewController

@property (nonatomic, strong) EZIoTDeviceInfo *deviceInfo;
@property (nonatomic, copy) NSString *recordType;

@end

NS_ASSUME_NONNULL_END
