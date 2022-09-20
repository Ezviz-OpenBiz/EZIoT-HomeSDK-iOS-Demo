//
//  EZIoTVoiceIntercomVC.h
//  EZIoTHomeSDKDemo
//
//  Created by yuqian on 2022/4/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    EZIoTVoiceIntercomypeAnswer, //接听
    EZIoTVoiceIntercomTypeCall, //呼叫
} EZIoTVoiceIntercomType;

typedef enum {
    EZIoTVoiceIntercomStatusAnswerWaiting, //接听等待
    EZIoTVoiceIntercomStatusCallWaiting, //呼叫等待
    EZIoTVoiceIntercomStatusTalking,  //对讲中
} EZIoTVoiceIntercomStatus;

@interface EZIoTVoiceIntercomVC : UIViewController

+ (instancetype) voiceIntercomWithType:(EZIoTVoiceIntercomType)type
                                 title:(NSString *)title
                              subTitle:(NSString *)subTitle;

@end

NS_ASSUME_NONNULL_END
