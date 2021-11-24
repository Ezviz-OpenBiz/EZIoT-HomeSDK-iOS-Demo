//
//  EZIoTDeviceProgressCell.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/26.
//

#import "EZIoTDeviceProgressCell.h"

@implementation EZIoTDeviceProgressCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}
- (IBAction)didChangeSliderValue:(id)sender {
    
    self.subTitleLabel.text = [NSString stringWithFormat:@"%d", (int)self.slider.value];
    
    if (self.didChangeCellSliderValue) {
        self.featureItem.value = [NSNumber numberWithInteger:self.slider.value];
        !self.didChangeCellSliderValue?:self.didChangeCellSliderValue(self.featureItem);
    }
}

@end
