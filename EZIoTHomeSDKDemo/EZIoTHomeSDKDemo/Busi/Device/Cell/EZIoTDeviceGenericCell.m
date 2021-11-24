//
//  EZIoTDeviceGenericCell.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/26.
//

#import "EZIoTDeviceGenericCell.h"

@implementation EZIoTDeviceGenericCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (IBAction)clickSettingBtn:(id)sender {
    
    if (self.didClickCellGenericBtn) {
        !self.didClickCellGenericBtn?:self.didClickCellGenericBtn(self.featureItem);
    }
}


@end
