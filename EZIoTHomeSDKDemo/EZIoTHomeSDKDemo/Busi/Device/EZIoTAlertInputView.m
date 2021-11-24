//
//  EZIoTAlertInputView.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/26.
//

#import "EZIoTAlertInputView.h"

@interface EZIoTAlertInputView()

@end

@implementation EZIoTAlertInputView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor =  [[UIColor blackColor] colorWithAlphaComponent:0.5];
}

- (IBAction)clickSendBtn:(id)sender
{
    if (self.clickSendBtn) {
        !self.clickSendBtn?:self.clickSendBtn(self.textView.text);
    }
}

- (IBAction)clickCancelBtn:(id)sender
{
    if (self.clickCancelBtn) {
        !self.clickCancelBtn?:self.clickCancelBtn();
        [self endEditing:YES];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}

@end
