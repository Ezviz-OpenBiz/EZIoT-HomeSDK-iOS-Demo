//
//  EZIoTBleControlVC.m
//  EZIoTHomeSDKDemo
//
//  Created by yuqian on 2022/3/16.
//

#import "EZIoTBleControlVC.h"
#import <Toast/Toast.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <EZIoTBluetoothSDK/EZIoTFeatureLiteConfigParam.h>
#import <EZIoTBluetoothSDK/EZIoTBLECenterMgr.h>


@interface EZIoTBleControlVC ()

@property (weak, nonatomic) IBOutlet UITextField *resourceIdInput;
@property (weak, nonatomic) IBOutlet UITextField *localIndexInput;
@property (weak, nonatomic) IBOutlet UITextField *domainInput;
@property (weak, nonatomic) IBOutlet UITextField *indentifierInput;
@property (weak, nonatomic) IBOutlet UITextField *versionInput;
@property (weak, nonatomic) IBOutlet UITextField *valueTypeInput;
@property (weak, nonatomic) IBOutlet UITextView *valueInput;

@end

@implementation EZIoTBleControlVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.ezPeripheral getNegotiatedMtu];
}

- (IBAction)clickGetBtn:(id)sender {   
    
    if (self.resourceIdInput.text == 0 ||
        self.localIndexInput.text == 0 ||
        self.domainInput.text == 0 ||
        self.indentifierInput.text == 0 ||
        self.versionInput.text == 0) {
        return;
    }
    
    EZIoTFeatureLiteConfigParam *param = [EZIoTFeatureLiteConfigParam new];
    param.resourceCategory = [self.resourceIdInput.text intValue];
    param.localIndex = [self.localIndexInput.text intValue];
    param.domain = [self.domainInput.text intValue];
    param.identifier = [self.indentifierInput.text intValue];
    param.version = [self.versionInput.text intValue];

//    param.resourceIdentifer = 0x1001;
//    param.localIndex = 0x5678;
//    param.domain = 0x1001;
//    param.identifier = 0x01;
//    param.version = 0x01;

    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[EZIoTBLECenterMgr sharedInstance] getPropFeature:self.ezPeripheral.devSerial featureParams:param completion:^(EZIoTPeripheral * _Nullable peripheral, NSArray<EZIoTFeatureLiteConfigParam *> * _Nonnull featureInfos, NSError * _Nullable error) {
            
        if (error)
        {
            [weakSelf showMessage:[NSString stringWithFormat:@"GetPropFeature  failed, error:%@", error]];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"GetPropFeature failed, error:%@", error);
        }
        else
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"GetPropFeature success, peripheral:%@", peripheral);
            [weakSelf showMessage:[NSString stringWithFormat:@"GetPropFeature success"]];
        }
        
    }];
}

- (IBAction)clickSetBtn:(id)sender {
    
    if (self.resourceIdInput.text == 0 ||
        self.localIndexInput.text == 0 ||
        self.domainInput.text == 0 ||
        self.indentifierInput.text == 0 ||
        self.versionInput.text == 0 ||
        self.valueTypeInput.text == 0 ||
        self.valueInput.text == 0) {
        return;
    }
    
    EZIoTFeatureLiteConfigParam *paramLite = [EZIoTFeatureLiteConfigParam new];
//    paramLite.deviceSerial = self.ezPeripheral.devSerial;
//    paramLite.resourceCategory = [self.resourceIdInput.text intValue];
//    paramLite.localIndex = [self.localIndexInput.text intValue];
//    paramLite.domain = [self.domainInput.text intValue];
//    paramLite.identifier = [self.indentifierInput.text intValue];
//    paramLite.version = [self.versionInput.text intValue];
//    paramLite.valueType = [self.valueTypeInput.text intValue];
    
//    paramLite.resourceCategory = 0;
//    paramLite.domain = 65000;
//    paramLite.identifier = 1;
//    paramLite.valueType = EZIoTFeatureValueTypeArray;
//    paramLite.value = @[@"17f03550000global_ManualFeed_1"  ,@"17f15550000global_ManualFeed_1",@"17f18550000global_ManualFeed_1",@"17f19550000global_ManualFeed_1",@"17f19570000global_ManualFeed_1",@"17f20550000global_ManualFeed_1",@"17f19580000global_ManualFeed_1",@"17f19580000global_ManualFeed_2"];
    
//    paramLite.domain = 129;
//    paramLite.identifier = 6;
//    paramLite.valueType = EZIoTFeatureValueTypeObject;
//    paramLite.value = @{@"timeZone":@"UTC+08:00", @"daylightSavingTime":@0};
    
    __weak typeof(self) weakSelf = self;
    [[EZIoTBLECenterMgr sharedInstance] setPropFeature:self.ezPeripheral.devSerial configParam:paramLite completion:^(EZIoTPeripheral * _Nullable peripheral,EZIoTFeatureLiteConfigParam * _Nullable value, NSError * _Nullable error) {
        if (error)
        {
            [weakSelf showMessage:[NSString stringWithFormat:@"SetPropFeature  failed, error:%@", error]];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"setPropFeature failed, error:%@", error);
        }
        else
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"setPropFeature success, peripheral:%@", peripheral);
            [weakSelf showMessage:[NSString stringWithFormat:@"SetPropFeature success"]];
        }
    }];
}

- (IBAction)clickSetActionBtn:(id)sender {
    
    EZIoTFeatureLiteConfigParam *param = [EZIoTFeatureLiteConfigParam new];
    param.resourceCategory = [self.resourceIdInput.text intValue];
    param.localIndex = [self.localIndexInput.text intValue];
    param.domain = [self.domainInput.text intValue];
    param.identifier = [self.indentifierInput.text intValue];
    param.version = [self.versionInput.text intValue];
    param.valueType = [self.valueTypeInput.text intValue];

//        param.resourceCategory = 0x5678;
//        param.localIndex = 0x1234;
//        param.domain = 0x1;
//        param.identifier = 0xA;
//        param.version = 0x01;
//        param.valueType = 0x01;


    EZIoTFeatureValueType valueType = param.valueType;
    NSString *valueInputStr = self.valueInput.text;

    switch (valueType) {
        case 0:
            param.value = [NSNumber numberWithBool:[valueInputStr boolValue]];
            break;
        case 1:
            param.value = [NSNumber numberWithInt:[valueInputStr intValue]];
            break;
        case 2:
            param.value = [NSNumber numberWithInt:[valueInputStr floatValue]];
            break;
        case 4:
        case 5:
        {
            NSData *jsonData = [valueInputStr dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            id value = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            param.value = value;
        }
            break;
        default:
            param.value = valueInputStr;
            break;
    }
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [[EZIoTBLECenterMgr sharedInstance] setActionFeature:self.ezPeripheral.devSerial configParam:param completion:^(EZIoTPeripheral * _Nullable peripheral, EZIoTFeatureLiteConfigParam * _Nullable value, NSError * _Nullable error) {
        
        if (error)
        {
            [weakSelf showMessage:[NSString stringWithFormat:@"setActionFeature  failed, error:%@", error]];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"setActionFeature failed, error:%@", error);
        }
        else
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"setActionFeature success, peripheral:%@", peripheral);
            [weakSelf showMessage:[NSString stringWithFormat:@"setActionFeature success"]];
        }
    }];
}

- (IBAction)clickNotiBtn:(id)sender {
        
    __weak typeof(self) weakSelf = self;
    [self showMessage:[NSString stringWithFormat:@"注册成功"]];
    [[EZIoTBLECenterMgr sharedInstance] registerFeatureListener:^(EZIoTPeripheral * _Nullable peripheral, NSArray<EZIoTFeatureLiteConfigParam *> * _Nonnull featureInfos, NSUInteger seqNum, NSUInteger cmdType, NSError * _Nullable error) {
        NSLog(@"registerFeatureListener success, peripheral:%@, propsFeatureInfo:%@", peripheral, featureInfos);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showMessage:[NSString stringWithFormat:@"Report- domain:%lu, identifier:%lu, value:%@",(unsigned long)featureInfos.firstObject.domain, (unsigned long)featureInfos.firstObject.identifier, featureInfos.firstObject.value]];
        });
    }];
}

- (void)showMessage:(NSString *)message
{
    [self.view makeToast:message duration:3.0 position:CSToastPositionCenter];
}

@end
