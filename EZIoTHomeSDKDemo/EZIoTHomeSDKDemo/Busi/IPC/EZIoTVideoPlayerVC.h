//
//  EZIoTVideoPlayerVC.h
//  EZIoTHomeSDKDemo
//
//  Created by yuqian on 2021/11/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EZIoTDeviceInfo,EZIoTLocalFile,EZIoTCloudFile;

@interface EZIoTVideoPlayerVC : UIViewController

@property (nonatomic, strong) EZIoTDeviceInfo *deviceInfo;
@property (nonatomic, strong) EZIoTLocalFile *localFile;
@property (nonatomic, strong) EZIoTCloudFile *cloudFile;
@property (nonatomic, copy) NSString *playeType;

@end

NS_ASSUME_NONNULL_END
