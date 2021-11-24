//
//  EZIoTAlertInputView.h
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZIoTAlertInputView : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;

@property (copy, nonatomic) void(^clickSendBtn)(NSString *content);
@property (copy, nonatomic) void(^clickCancelBtn)(void);

@end

NS_ASSUME_NONNULL_END
