//
//  EZIoTDeviceProgressCell.h
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/26.
//

#import <UIKit/UIKit.h>
#import <EZIoTDeviceSDK/EZIoTDeviceSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZIoTDeviceProgressCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@property (strong, nonatomic) EZIoTPropertyFeatureItem *featureItem;
@property (copy, nonatomic) void(^didChangeCellSliderValue)(EZIoTPropertyFeatureItem *featureItem);

@end

NS_ASSUME_NONNULL_END
