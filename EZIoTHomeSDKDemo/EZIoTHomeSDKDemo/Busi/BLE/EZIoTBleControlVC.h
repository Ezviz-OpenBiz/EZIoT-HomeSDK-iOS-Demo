//
//  EZIoTBleControlVC.h
//  EZIoTHomeSDKDemo
//
//  Created by yuqian on 2022/3/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EZIoTPeripheral;

@interface EZIoTBleControlVC : UITableViewController

@property (strong, nonatomic) EZIoTPeripheral *ezPeripheral;

@end

NS_ASSUME_NONNULL_END
