//
//  EZIoTPaintView.h
//  NetTest
//
//  Created by yuqian on 2021/12/21.
//  Copyright © 2021 com.hikvision.ezviz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZIoTPaintView : UIView

@property (nonatomic,strong)NSMutableArray *pointArray;
@property (nonatomic,copy) void (^paintDidSelectedVertex)(NSMutableArray *pointArray);

@end

NS_ASSUME_NONNULL_END
