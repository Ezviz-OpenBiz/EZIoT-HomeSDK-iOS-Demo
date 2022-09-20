//
//  EZIoTVideoPlayerVC.m
//  EZIoTHomeSDKDemo
//
//  Created by yuqian on 2021/11/25.
//

#import "EZIoTVideoPlayerVC.h"
#import <Toast/Toast.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <EZIoTDeviceSDK/EZIoTDeviceInfo+Extension.h>
#import <EZIoTDeviceSDK/EZIoTResourceInfo+AccessDB.h>

#import "EZIoTLocalFile.h"
#import "EZIoTCloudFile.h"
#import "EZIoTVideoPlayer.h"
#import "EZIoTIntercomPlayer.h"
#import "EZIoTVideoRhythmVC.h"



@interface EZIoTVideoPlayerVC ()  <EZIoTPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIView *perviewView;
@property (weak, nonatomic) IBOutlet UIButton *talkBtn;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *captureBtn;

@property(strong, nonatomic) EZIoTVideoPlayer *videoPlayer;
@property(strong, nonatomic) EZIoTIntercomPlayer *intercomPlayer;

@end

@implementation EZIoTVideoPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self startStream];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.recordBtn.selected) {
        [self.navigationController.view makeToast:@"结束录像"  duration:2.0 position:CSToastPositionCenter];
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopRecord];
    [self stopStream];
}

- (IBAction)clickRecordBtn:(UIButton *)sender {

    __weak typeof(self) weakSelf = self;
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self.videoPlayer startRecord:^{
            
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            NSLog(@"Video record start.");
            [weakSelf.view makeToast:@"开始录制"  duration:2.0 position:CSToastPositionCenter];
                
        } failure:^(NSError * _Nonnull error) {
            sender.selected = !sender.selected;
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            NSLog(@"Video record failed. ErrorCode: %ld", (long)error.code);
            [weakSelf.view makeToast:[NSString stringWithFormat:@"录像失败%ld",(long)error.code]  duration:3.0 position:CSToastPositionCenter];
        }];
    }
    else
    {
        [self stopRecord];
    }
}

- (IBAction)clickCaptureBtn:(UIButton *)sender {
    
    NSString *tmpPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Capture"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *imageFile = [tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", dateStr]];

    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self.videoPlayer capture:^(UIImage * _Nonnull image) {
            
        BOOL result = [UIImagePNGRepresentation(image) writeToFile:imageFile atomically:YES];
        if (result) {
            NSLog(@"抓图保存成功。");
        }

        [weakSelf.view makeToast:@"抓图成功"  duration:2.0 position:CSToastPositionCenter];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:[NSString stringWithFormat:@"抓图失败%ld",(long)error.code]  duration:3.0 position:CSToastPositionCenter];
        NSLog(@"Image capture failed. ErrorCode: %ld", (long)error.code);
    }];
}

- (IBAction)clickTalkBtn:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    [self cameraIntercom:sender.selected];
}

- (void)cameraIntercom:(BOOL)speak {
    
    if (speak)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self.videoPlayer openSound:NO];
        [self.intercomPlayer start];
    }
    else {
        
        [self.intercomPlayer stop];
        [self.videoPlayer openSound:YES];
    }
}

- (IBAction)clickVideoRhythmBtn:(id)sender
{
    // 需要先进行视频抓图
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.videoPlayer capture:^(UIImage * _Nonnull image) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
//    NSString *tmpPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Capture"];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
//        NSError *error;
//        [[NSFileManager defaultManager] createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:&error];
//    }
//    NSString *imageFile = [tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"20211221163711.png"]];
//    UIImage *image = [UIImage imageWithContentsOfFile:imageFile];
        [self performSegueWithIdentifier: @"ShowVideoRhythmVC" sender:image];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:[NSString stringWithFormat:@"抓图失败，视频律动需要先进行抓图(%ld)",(long)error.code]  duration:3.0 position:CSToastPositionCenter];
        NSLog(@"Image capture failed. ErrorCode: %ld", (long)error.code);
    }];
}

#pragma mark - EZIoTVideoPlayerDelegate
- (void)player:(id)player playState:(EZIoTPlayerStatus)playState error:(NSError * _Nullable)error
{
    switch (playState) {
        case EZIoTPlayerStatusLoad:
            break;
        case EZIoTPlayerStatusDoing:
            [self showPlayInfo];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            break;

        case EZIoTPlayerStatusStop: {
        
            if (self.recordBtn.selected) {
                [self.view makeToast:@"结束录像"  duration:2.0 position:CSToastPositionCenter];
                self.recordBtn.selected = NO;
            }
            
            if (error)
            {
                if (error.code == 200021 || error.code == 200025) {
                    [self showRetry];
                }
                else
                    [self.view makeToast:[NSString stringWithFormat:@"error:%zd ", error.code] duration:3.0 position:CSToastPositionCenter];
            }
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            break;
        }

        default:
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            break;
    }
}

- (void)showPlayInfo {
    NSString *streamFetchType = @"";
    switch ([self.videoPlayer streamFetchType]) {
        case EZIoTStreamFetchTypePrivate:
            streamFetchType = @"0-VTDU";
            break;
        case EZIoTStreamFetchTypeP2p:
            streamFetchType = @"1-P2P";
            break;
        case EZIoTStreamFetchTypeDirectInner:
            streamFetchType = @"2-DirectInner";
            break;
        case EZIoTStreamFetchTypeDirectOuter:
            streamFetchType = @"3-DirectOuter";
            break;
        case EZIoTStreamFetchTypeCloudPlayback:
            streamFetchType = @"4-CloudPlayback";
            break;
        case EZIoTStreamFetchTypeCloudRecord:
            streamFetchType = @"5-CloudRecord";
            break;
        case EZIoTStreamFetchTypeDirectReverse:
            streamFetchType = @"6-DirectReverse";
            break;
        case EZIoTStreamFetchTypeNetSDKLAN:
            streamFetchType = @"7-HCNetSDK";
            break;
        case EZIoTStreamFetchTypeProxy:
            streamFetchType = @"8-代理";
            break;
        default:
            streamFetchType = @"-1-None";
            break;
    }

    NSString *engine = @"未知";
    if ([self.videoPlayer isHard]) {
        engine = @"硬解";
    }
    else{
        engine = @"软解";
    }

    NSString *streamType = @"";
    switch ([self.videoPlayer streamType]) {
        case EZIoTMainStreamType:
            streamType = @"主码流";
            break;
        case EZIoTSubStreamType:
            streamType = @"子码流";
            break;
        default:
            streamType = @"未知";
            break;
    }
    
    [self.view makeToast:[NSString stringWithFormat:@"|%@|%@|%@|", streamFetchType, engine, streamType] duration:2.0 position:CSToastPositionCenter];
}

- (void)showSetPassword
{
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请输入视频加密密码" message:@"您的视频已加密，请输入密码进行查看，初始密码为机身标签上的验证码。（密码区分大小写)" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *codeInput = alertVC.textFields.firstObject.text;
        NSLog(@"codeInput: %@", codeInput);
        [weakSelf.deviceInfo saveDevicePassword:codeInput];
        [weakSelf.deviceInfo saveCloudPassword:codeInput];
        [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        [weakSelf.videoPlayer start];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    [alertVC addAction:actionConfirm];
    [alertVC addAction:actionCancel];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)showRetry
{
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"设备密码错误" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf showSetPassword];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:actionConfirm];
    [alertVC addAction:actionCancel];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    EZIoTVideoRhythmVC *vc = segue.destinationViewController;
    vc.captureImage = sender;
    vc.deviceInfo = self.deviceInfo;
}

- (void) stopRecord
{
    if (self.videoPlayer)
    {
        self.recordBtn.selected = NO;
        __weak typeof(self) weakSelf = self;
        [self.videoPlayer stopRecord:^(NSString * _Nonnull saveRecordPath) {
            
            [weakSelf.view makeToast:@"结束录像"  duration:3.0 position:CSToastPositionCenter];
            
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"Video record failed. ErrorCode: %ld", (long)error.code);
            [weakSelf.view makeToast:[NSString stringWithFormat:@"录像失败%ld",(long)error.code]  duration:3.0 position:CSToastPositionCenter];
        }];
    }
}

- (void) startStream
{
    EZIoTResourceInfo *resourceInfo;
    for (EZIoTResourceInfo *obj in [EZIoTResourceInfo getResourcesByDeviceSerial:self.deviceInfo.deviceSerial]) {
        if (obj.isCamera) {
            resourceInfo = obj;
            break;
        }
    }
    if ([self.playeType isEqualToString:@"Preview"])
    {
        self.videoPlayer = [EZIoTVideoPlayer realPlayWithDeviceInfo:self.deviceInfo resourceInfo:resourceInfo playView:self.perviewView];
        self.intercomPlayer = [EZIoTIntercomPlayer intercomWithDeviceInfo:self.deviceInfo resourceInfo:resourceInfo];
        self.intercomPlayer.delegate = self;
    }
    else if([self.playeType isEqualToString:@"DevicePlayback"])
    {
        self.title = @"设备回放";
        self.videoPlayer = [EZIoTVideoPlayer playbackWithDeviceInfo:self.deviceInfo resourceInfo:resourceInfo playView:self.perviewView videoType:EZIoTPlaybackVideoTypeDevice recordFile:self.localFile];
        
        self.talkBtn.hidden = YES;
    }
    else if([self.playeType isEqualToString:@"CloudPlayback"])
    {
        self.title = @"云录像回放";
        self.videoPlayer = [EZIoTVideoPlayer playbackWithDeviceInfo:self.deviceInfo resourceInfo:resourceInfo playView:self.perviewView videoType:EZIoTPlaybackVideoTypeCloud recordFile:self.cloudFile];
        self.talkBtn.hidden = YES;
    }
    self.videoPlayer.delegate = self;
    
    if (self.deviceInfo.isEncrypt)
    {
        if ([self.deviceInfo getDevicePassword].length > 0)
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self.videoPlayer start];
        }
        else
        {
            [self showSetPassword];
        }
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self.videoPlayer start];
    }
}

- (void) stopStream
{
    if (self.videoPlayer) {
        [self.videoPlayer stop];
        [self.videoPlayer destroy];
        self.videoPlayer = nil;
    }
    if (self.intercomPlayer) {
        [self.intercomPlayer stop];
        [self.intercomPlayer destroy];
        self.intercomPlayer = nil;
    }
}

- (void) applicationBecomeActive
{
    [self startStream];
}

- (void) applicationEnterBackground
{
    [self stopStream];
}

@end
