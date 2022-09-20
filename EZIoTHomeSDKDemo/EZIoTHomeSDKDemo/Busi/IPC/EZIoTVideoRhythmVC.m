//
//  EZIoTVideoRhythmVC.m
//  EZIoTHomeSDKDemo
//
//  Created by yuqian on 2021/12/21.
//

#import "EZIoTVideoRhythmVC.h"
#import "EZIoTPaintView.h"
#import <Masonry/Masonry.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>
#import <EZIoTDeviceSDK/EZIoTDeviceSDK.h>
#import <EZIoTDeviceSDK/EZIoTResourceInfo+AccessDB.h>


@interface EZIoTVideoRhythmVC () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *captureView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captureViewH;

@property (weak, nonatomic) IBOutlet UITextField *ipInput;
@property (weak, nonatomic) IBOutlet UILabel *vertexLabel;
@property (weak, nonatomic) IBOutlet UIButton *mode1;
@property (weak, nonatomic) IBOutlet UIButton *mode2;
@property (weak, nonatomic) IBOutlet UIButton *mode3;
@property (weak, nonatomic) IBOutlet UIButton *mode4;
@property (weak, nonatomic) IBOutlet UIButton *mode5;
@property (weak, nonatomic) IBOutlet UITextField *upLabInput;
@property (weak, nonatomic) IBOutlet UITextField *leftLabInput;
@property (weak, nonatomic) IBOutlet UITextField *downLabInput;
@property (weak, nonatomic) IBOutlet UITextField *rightLabInput;

@property (strong, nonatomic) EZIoTResourceInfo *resourceInfo;
@property (strong, nonatomic) NSArray *btnArray;
@property (strong, nonatomic) EZIoTPaintView *paintView;

@end

@implementation EZIoTVideoRhythmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (EZIoTResourceInfo *obj in [EZIoTResourceInfo getResourcesByDeviceSerial:self.deviceInfo.deviceSerial]) {
        if (obj.isCamera) {
            self.resourceInfo = obj;
            break;
        }
    }
    
    self.title = @"视频律动";
    self.btnArray = @[self.mode1, self.mode2, self.mode3, self.mode4, self.mode5];
    
    CGFloat width = CGImageGetWidth(_captureImage.CGImage);
    CGFloat height = CGImageGetHeight(_captureImage.CGImage);
    
    self.captureViewH.constant = UIScreen.mainScreen.bounds.size.width*height/width;
    NSLog(@"captureViewH: %f", self.captureViewH.constant);
    self.captureView.image = _captureImage;
    
    self.paintView = [EZIoTPaintView new];
    self.paintView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.paintView];
    [self.paintView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.captureView);
    }];
    __weak typeof(self) weakSelf = self;
    self.paintView.paintDidSelectedVertex = ^(NSMutableArray * _Nonnull pointArray) {
        
        NSMutableString *vertexes = [NSMutableString string];
        for (NSInteger i = 0; i < pointArray.count; i++)
        {
            CGPoint point= CGPointFromString([pointArray objectAtIndex:i]);
            
            float x = point.x/self.captureView.bounds.size.width;
            float y = point.y/self.captureView.bounds.size.height;
            [vertexes appendString:[NSString stringWithFormat:@"(%0.2f,%0.2f)", x, y]];
        }
        
        weakSelf.vertexLabel.text = vertexes;
    };
}

- (IBAction)clickAssociatedLamp:(id)sender
{
    if (self.ipInput.text.length == 0) {
        [self.view makeToast:@"清输入灯带ip"  duration:3.0 position:CSToastPositionCenter];
        return;
    }
    
    EZIoTPropertyFeatureItem * featureItem = [EZIoTPropertyFeatureItem new];
    featureItem.deviceSerial = self.deviceInfo.deviceSerial;
    featureItem.resourceIdentifier = @"Video";
    featureItem.localIndex = self.resourceInfo.localIndex;
    featureItem.domainIdentifier = @"VideoRhythm";
    featureItem.propertyIdentifier = @"AssociateLamp";
    featureItem.value = @{@"ip":self.ipInput.text, @"status":@(-1)};
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTDeviceManager setPropertyFeatureValuesWithItem:featureItem success:^{
            
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"灯带关联成功");
        [weakSelf.navigationController.view makeToast:@"灯带关联成功"  duration:3.0 position:CSToastPositionCenter];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"error: %@", error);
        
        if (error.code == 31030) {
            [weakSelf.navigationController.view makeToast:@"您无操作此设备的权限"  duration:3.0 position:CSToastPositionCenter];
        }
        else{
            [weakSelf.navigationController.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
        }
    }];
}

- (IBAction)clickModeSelect:(UIButton *)sender
{
    if (self.paintView.pointArray.count < 4) {
        [self.view makeToast:@"清先选择区域"  duration:3.0 position:CSToastPositionCenter];
        return;
    }
    
    for (UIButton *btn in self.btnArray) {
        
        if (sender.tag == btn.tag)
        {
            sender.selected = YES;
        }
        else
        {
            btn.selected = NO;
        }
    }
    int mode = sender.tag%100;
    NSLog(@"mode:%d", mode);
    
    EZIoTPropertyFeatureItem * featureItem = [EZIoTPropertyFeatureItem new];
    featureItem.deviceSerial = self.deviceInfo.deviceSerial;
    featureItem.resourceIdentifier = @"Video";
    featureItem.localIndex = self.resourceInfo.localIndex;
    featureItem.domainIdentifier = @"VideoRhythm";
    featureItem.propertyIdentifier = @"VideoAreaModeSetting";
    
    CGPoint poinLeftUp = CGPointFromString([self.paintView.pointArray objectAtIndex:0]);
    CGPoint poinLeftDown = CGPointFromString([self.paintView.pointArray objectAtIndex:1]);
    CGPoint poinRightDown = CGPointFromString([self.paintView.pointArray objectAtIndex:2]);
    CGPoint poinRightUp = CGPointFromString([self.paintView.pointArray objectAtIndex:3]);

    
    featureItem.value = @{@"vertex":@[@{@"leftUp":@{@"x":
                                                        @(floor(poinLeftUp.x/self.captureView.bounds.size.width * 1000)),
                                                    @"y":
                                                        @(floor(poinLeftUp.y/self.captureView.bounds.size.height * 1000))}},
                                      @{@"leftDown":@{@"x":
                                                          @(floor(poinLeftDown.x/self.captureView.bounds.size.width * 1000)),
                                                      @"y":
                                                          @(floor(poinLeftDown.y/self.captureView.bounds.size.height * 1000))}},
                                      @{@"rightDown":@{@"x":
                                                           @(floor(poinRightDown.x/self.captureView.bounds.size.width * 1000)),
                                                       @"y":
                                                           @(floor(poinRightDown.y/self.captureView.bounds.size.height * 1000))}},
                                      @{@"rightUp":@{@"x":
                                                         @(floor(poinRightUp.x/self.captureView.bounds.size.width * 1000)),
                                                     @"y":
                                                         @(floor(poinRightUp.y/self.captureView.bounds.size.height * 1000))}}],
                          @"mode":@(mode)};

    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTDeviceManager setPropertyFeatureValuesWithItem:featureItem success:^{

        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"律动区域模式设置成功");
        [weakSelf.navigationController.view makeToast:@"律动区域模式设置成功"  duration:3.0 position:CSToastPositionCenter];

    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"error: %@", error);

        if (error.code == 31030) {
            [weakSelf.navigationController.view makeToast:@"您无操作此设备的权限"  duration:3.0 position:CSToastPositionCenter];
        }
        else{
            [weakSelf.navigationController.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
        }
    }];
}

- (IBAction)clickLampInstall:(id)sender {

    if (self.upLabInput.text.length == 0 ||
        self.leftLabInput.text.length == 0 ||
        self.downLabInput.text.length == 0 ||
        self.rightLabInput.text.length == 0) {
        
        
        EZIoTPropertyFeatureItem * featureItem = [EZIoTPropertyFeatureItem new];
        featureItem.deviceSerial = self.deviceInfo.deviceSerial;
        featureItem.resourceIdentifier = @"Video";
        featureItem.localIndex = self.resourceInfo.localIndex;
        featureItem.domainIdentifier = @"VideoRhythm";
        featureItem.propertyIdentifier = @"LampInstallSetting";
        featureItem.value = @{@"leftNum":@([self.leftLabInput.text intValue]),
                              @"downNum":@([self.downLabInput.text intValue]),
                              @"rightNum":@([self.rightLabInput.text intValue]),
                              @"upNum":@([self.upLabInput.text intValue])};
        
        __weak typeof(self) weakSelf = self;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [EZIoTDeviceManager setPropertyFeatureValuesWithItem:featureItem success:^{
                
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            NSLog(@"灯带安装设置成功");
            [weakSelf.navigationController.view makeToast:@"灯带安装设置成功"  duration:3.0 position:CSToastPositionCenter];
            
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            NSLog(@"error: %@", error);
            
            if (error.code == 31030) {
                [weakSelf.navigationController.view makeToast:@"您无操作此设备的权限"  duration:3.0 position:CSToastPositionCenter];
            }
            else{
                [weakSelf.navigationController.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
            }
        }];
    }
}

- (IBAction)rhythmControl:(UIButton *)sender
{
    EZIoTPropertyFeatureItem * featureItem = [EZIoTPropertyFeatureItem new];
    featureItem.deviceSerial = self.deviceInfo.deviceSerial;
    featureItem.resourceIdentifier = @"Video";
    featureItem.localIndex = self.resourceInfo.localIndex;
    featureItem.domainIdentifier = @"VideoRhythm";
    featureItem.propertyIdentifier = @"RhythmControl";
    BOOL status = sender.tag == 201;
    featureItem.value = [NSNumber numberWithBool:status];
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTDeviceManager setPropertyFeatureValuesWithItem:featureItem success:^{
            
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(status?@"开始律动":@"停止律动");
        [weakSelf.navigationController.view makeToast:status?@"开始律动":@"停止律动"  duration:3.0 position:CSToastPositionCenter];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"error: %@", error);
        
        if (error.code == 31030) {
            [weakSelf.navigationController.view makeToast:@"您无操作此设备的权限"  duration:3.0 position:CSToastPositionCenter];
        }
        else{
            [weakSelf.navigationController.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

@end
