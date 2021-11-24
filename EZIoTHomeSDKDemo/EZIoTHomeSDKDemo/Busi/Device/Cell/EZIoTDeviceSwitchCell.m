//
//  EZIoTDeviceSwitchCell.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/26.
//

#import "EZIoTDeviceSwitchCell.h"

@implementation EZIoTDeviceSwitchCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (IBAction)didChangeSwitchValue:(id)sender {
    
    if (self.didChangeCellSwitchValue) {
        self.featureItem.value = [NSNumber numberWithBool:self.statusSwitch.on];
        !self.didChangeCellSwitchValue?:self.didChangeCellSwitchValue(self.featureItem);
    }
}

@end
