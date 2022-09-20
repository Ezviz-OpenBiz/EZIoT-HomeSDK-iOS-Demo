//
//  EZIoTVoiceIntercomVC.m
//  EZIoTHomeSDKDemo
//
//  Created by yuqian on 2022/4/25.
//

#import "EZIoTVoiceIntercomVC.h"

@interface EZIoTVoiceIntercomVC ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *micControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *speakerBtn;
@property (weak, nonatomic) IBOutlet UIButton *hangupBtn;
@property (weak, nonatomic) IBOutlet UIButton *answerBtn;

@property (nonatomic, assign) EZIoTVoiceIntercomType type;
@property (nonatomic, assign) EZIoTVoiceIntercomStatus status;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) NSString *mainTitle;
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, assign) int hour;
@property (nonatomic, assign) int min;
@property (nonatomic, assign) int second;

@end

@implementation EZIoTVoiceIntercomVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_micControlBtn setImage:[UIImage imageNamed:@"icon_maikefeng_open"] forState:UIControlStateSelected];
    [_speakerBtn setImage:[UIImage imageNamed:@"iconu_yangshengqi_open"] forState:UIControlStateSelected];
    
//    [_micControlBtn setTitle:@"" forState:UIControlStateNormal];
//    [_micControlBtn setTitle:@"" forState:UIControlStateSelected];
//    [_speakerBtn setTitle:@"" forState:UIControlStateNormal];
//    [_speakerBtn setTitle:@"" forState:UIControlStateSelected];
    if (self.type == EZIoTVoiceIntercomTypeCall)
    {
        _answerBtn.hidden = YES;
        _hangupBtn.transform = CGAffineTransformMakeTranslation(self.view.center.x - self.hangupBtn.center.x, 0);
        _status = EZIoTVoiceIntercomStatusAnswerWaiting;
        _titleLabel.text = @"呼叫中";
        _subTitleLabel.hidden = YES;
    }
    else
    {
        _micControlBtn.hidden = YES;
        _speakerBtn.hidden = YES;
        _status = EZIoTVoiceIntercomStatusCallWaiting;
        _titleLabel.text = self.mainTitle;
        _subTitleLabel.text = self.subTitle;
    }
    
    [self addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - Control

- (IBAction)clickMicBtn:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
}

- (IBAction)clickSpeakerBtn:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
}

- (IBAction)clickHangupBtn:(UIButton *)sender
{
    [self.timer invalidate];
    self.timer = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickAnswerBtn:(UIButton *)sender
{
    self.status = EZIoTVoiceIntercomStatusTalking;
    [self startTimer];
    _titleLabel.text = @"通话中";
    _subTitleLabel.hidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        sender.hidden = YES;
        self->_micControlBtn.hidden = NO;
        self->_speakerBtn.hidden = NO;
        self.hangupBtn.transform = CGAffineTransformMakeTranslation(self.view.center.x - self.hangupBtn.center.x, 0);
    }];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"])
    {
        
    }
}

#pragma mark - Private

- (void) startTimer
{
    self.subTitleLabel.text = @"00 : 00";
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeLabel) userInfo:nil repeats:YES];
}

- (void)updateTimeLabel
{
    if (++_second == 60) {
        ++_min;
        _second = 0;
    }
    if (_min == 60) {
        ++_hour;
        _min = 0;
    }
    if (_hour > 0) {
        self.subTitleLabel.text = [NSString stringWithFormat:@"%02d : %02d : %02d", _hour, _min, _second];
    }
    else {
        self.subTitleLabel.text = [NSString stringWithFormat:@"%02d : %02d", _min, _second];
    }
    
//    if (_min == 5) {
//        self.normalTipLabel.hidden = NO; //5分钟后提示
//    }
}

#pragma mark - Init & Dealloc

+ (instancetype) voiceIntercomWithType:(EZIoTVoiceIntercomType)type
                                 title:(NSString *)title
                              subTitle:(NSString *)subTitle
{
    
    EZIoTVoiceIntercomVC *vc =  [[UIStoryboard storyboardWithName:@"EZIoTIntercom" bundle:nil] instantiateViewControllerWithIdentifier:@"EZIoTVoiceIntercomVC"];
    vc.type = type;
    vc.mainTitle = title;
    vc.subTitle = subTitle;
    return vc;
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"status"];
    [self.timer invalidate];
    self.timer = nil;
}

@end
