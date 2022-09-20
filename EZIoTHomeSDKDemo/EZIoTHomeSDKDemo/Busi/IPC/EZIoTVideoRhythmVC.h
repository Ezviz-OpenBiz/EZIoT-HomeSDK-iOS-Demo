//
//  EZIoTVideoRhythmVC.h
//  EZIoTHomeSDKDemo
//
//  Created by yuqian on 2021/12/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EZIoTDeviceInfo;

@interface EZIoTVideoRhythmVC : UIViewController

@property (nonatomic, strong) EZIoTDeviceInfo *deviceInfo;
@property (nonatomic, strong) UIImage *captureImage;

@end

NS_ASSUME_NONNULL_END
