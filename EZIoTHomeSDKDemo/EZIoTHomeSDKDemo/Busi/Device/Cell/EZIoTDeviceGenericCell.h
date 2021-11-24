//
//  EZIoTDeviceGenericCell.h
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/26.
//

#import <UIKit/UIKit.h>
#import <EZIoTDeviceSDK/EZIoTDeviceSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZIoTDeviceGenericCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *settingBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) EZIoTFeatureItem *featureItem;
@property (copy, nonatomic) void(^didClickCellGenericBtn)(EZIoTFeatureItem *featureItem);

@end

NS_ASSUME_NONNULL_END
