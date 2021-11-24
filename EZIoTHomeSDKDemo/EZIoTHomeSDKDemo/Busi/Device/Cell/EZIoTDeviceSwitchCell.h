//
//  EZIoTDeviceSwitchCell.h
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/26.
//

#import <UIKit/UIKit.h>
#import <EZIoTDeviceSDK/EZIoTDeviceSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZIoTDeviceSwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISwitch *statusSwitch;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) EZIoTPropertyFeatureItem *featureItem;
@property (copy, nonatomic) void(^didChangeCellSwitchValue)(EZIoTPropertyFeatureItem *featureItem);

@end

NS_ASSUME_NONNULL_END
