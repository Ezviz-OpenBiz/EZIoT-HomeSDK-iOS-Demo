//
//  EZIoTDeviceDetailVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/22.
//

#import "EZIoTDeviceDetailVC.h"
#import <EZIoTDeviceSDK/EZIoTDeviceSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>

#import "EZIoTDeviceSwitchCell.h"
#import "EZIoTDeviceProgressCell.h"
#import "EZIoTDeviceGenericCell.h"
#import "EZIoTDeviceFeatureDetailVC.h"
#import "EZIoTDeviceSettingVC.h"
#import "EZIoTAlertInputView.h"

//#import <EZIoTDeviceSDK/EZIoTDeviceManager+Feature.h>


@interface EZIoTDeviceDetailVC ()

@property (nonatomic, strong) NSMutableArray *featuresList;

@end

@implementation EZIoTDeviceDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = self.deviceInfo.status != 1 ? [NSString stringWithFormat:@"(离线)%@", self.deviceInfo.name] : self.deviceInfo.name;
    self.featuresList = [NSMutableArray arrayWithArray:self.deviceInfo.propFeatureItems];
    [self.featuresList addObjectsFromArray:self.deviceInfo.actionFeatureItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (IBAction)clickSettingBtn:(id)sender {
    
    [self performSegueWithIdentifier: @"ShowSettingDetail" sender:self.deviceInfo];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.featuresList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EZIoTFeatureItem *featureItem = self.featuresList[indexPath.row];
    NSString *reusedId = [self cellReusedIdentifier:featureItem];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedId forIndexPath:indexPath];
    EZIoTResourceInfo *resourceInfo = [EZIoTResourceInfo getResourcesByDeviceSerial:self.deviceInfo.deviceSerial].firstObject;
    
    if (self.deviceInfo.status != 1 || resourceInfo.isShared != 0) {
        cell.contentView.userInteractionEnabled = NO;
        cell.contentView.alpha = 0.6;
    }
    else
    {
        cell.contentView.userInteractionEnabled = YES;
        cell.contentView.alpha = 1;
    }
    
    __weak typeof(self) weakSelf = self;
    if ([reusedId isEqualToString:@"EZIoTDeviceSwitchCell"])
    {
        EZIoTDeviceSwitchCell *switchCell = (EZIoTDeviceSwitchCell *)cell;
        
        EZIoTPropertyFeatureItem *pFeatureItem = (EZIoTPropertyFeatureItem *)featureItem;
        switchCell.statusSwitch.on = [pFeatureItem.value boolValue];
        
        pFeatureItem.name = pFeatureItem.name.length > 0 ? pFeatureItem.name : pFeatureItem.identifier;
        switchCell.titleLabel.text = [pFeatureItem.access isEqualToString:@"rw"] ? pFeatureItem.name : [NSString stringWithFormat:@"(仅上报)%@", pFeatureItem.name];
        switchCell.featureItem = pFeatureItem;
        switchCell.statusSwitch.enabled = [pFeatureItem.access isEqualToString:@"rw"];
        
        switchCell.didChangeCellSwitchValue = ^(EZIoTPropertyFeatureItem * _Nonnull featureItem) {
                        
            [weakSelf setFeatureValue:featureItem];
        };
        
        return switchCell;
    }
    else if ([reusedId isEqualToString:@"EZIoTDeviceProgressCell"])
    {
        EZIoTDeviceProgressCell *progressCell = (EZIoTDeviceProgressCell *)cell;
        EZIoTPropertyFeatureItem *pFeatureItem = (EZIoTPropertyFeatureItem *)featureItem;
        pFeatureItem.name = pFeatureItem.name.length > 0 ? pFeatureItem.name : pFeatureItem.identifier;
        
        progressCell.titleLabel.text = [pFeatureItem.access isEqualToString:@"rw"] ? pFeatureItem.name : [NSString stringWithFormat:@"(只读)%@", pFeatureItem.name];
        progressCell.slider.minimumValue = pFeatureItem.schema[@"minimum"] ? [pFeatureItem.schema[@"minimum"] integerValue] : 0;
        progressCell.slider.maximumValue = pFeatureItem.schema[@"maximum"] ? [pFeatureItem.schema[@"maximum"] integerValue] : 100;
        progressCell.slider.value = pFeatureItem.value ? [pFeatureItem.value integerValue] : 0;
        progressCell.subTitleLabel.text = [NSString stringWithFormat:@"%@", pFeatureItem.value ?: @"0"];
        progressCell.featureItem = pFeatureItem;
        progressCell.slider.enabled = [pFeatureItem.access isEqualToString:@"rw"];
        
        progressCell.didChangeCellSliderValue = ^(EZIoTPropertyFeatureItem * _Nonnull featureItem) {
            
            if ([pFeatureItem.schema[@"multipleOf"] integerValue] == 10) {
                NSInteger rawValue = [featureItem.value integerValue];
                featureItem.value = @(rawValue/10*10);
            }
            [weakSelf setFeatureValue:featureItem];
        };
        
        return progressCell;
    }
    else
    {
        EZIoTDeviceGenericCell *genericCell = (EZIoTDeviceGenericCell *)cell;
        
        featureItem.name = featureItem.name.length > 0 ? featureItem.name : featureItem.identifier;
        genericCell.titleLabel.text = featureItem.name;
        genericCell.featureItem = featureItem;
        genericCell.settingBtn.enabled = YES;
        
        if ([featureItem isKindOfClass:[EZIoTPropertyFeatureItem class]])
        {
            EZIoTPropertyFeatureItem *pFeatureItem = (EZIoTPropertyFeatureItem *)featureItem;
            genericCell.settingBtn.enabled = [pFeatureItem.access isEqualToString:@"rw"];
            genericCell.titleLabel.text = [pFeatureItem.access isEqualToString:@"rw"] ? pFeatureItem.name : [NSString stringWithFormat:@"(仅上报)%@", pFeatureItem.name];
        }
        
        genericCell.didClickCellGenericBtn = ^(EZIoTFeatureItem * _Nonnull featureItem) {
            
            if ([featureItem.type containsString:@"enum"])
            {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"功能点枚举值选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                NSArray *enumData = featureItem.schema[@"enum"];
                for (id item in enumData)
                {
                    UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@", item] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        //功能点下发
                        if ([featureItem.type containsString:@"integer"] ||
                            [featureItem.type containsString:@"number"])
                        {
                            featureItem.value = [NSNumber numberWithInt:[item intValue]];
                        }
                        else if ([featureItem.type containsString:@"boolean"]) {
                            featureItem.value = [NSNumber numberWithBool:[item boolValue]];
                        }
                        else{
                            featureItem.value = item;
                        }
                        
                        [weakSelf setFeatureValue:featureItem];
                    }];
                    [alertVC addAction:action];
                }
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                [alertVC addAction:action];
                [self presentViewController:alertVC animated:YES completion:nil];
            }
            else
            {
                EZIoTAlertInputView *alertInputView = [[NSBundle mainBundle] loadNibNamed:@"EZIoTAlertInputView" owner:self options:nil].firstObject;
                alertInputView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
                __weak EZIoTAlertInputView *weakInputView = alertInputView;
                alertInputView.clickCancelBtn = ^{
                    [weakInputView removeFromSuperview];
                };
                
                if ([featureItem.type isEqualToString:@"boolean"])
                {
                    weakInputView.textView.text = @"请输入功能点的值。类型为boolean：0/1.";
                }
                else if ([featureItem.type isEqualToString:@"integer"] ||
                         [featureItem.type isEqualToString:@"number"])
                {
                    weakInputView.textView.text = @"请输入功能点的值。类型为integer/number.";
                }
                else if ([featureItem.type isEqualToString:@"string"])
                {
                    weakInputView.textView.text = @"请输入功能点的值。类型为string.";
                }
                else if ([featureItem.type isEqualToString:@"object"])
                {
                    weakInputView.textView.text = @"请输入功能点的值。类型为object：{\"key1\" : \"string\", \"key2\" : 0}";
                }
                else if ([featureItem.type isEqualToString:@"array"])
                {
                    weakInputView.textView.text = @"请输入功能点的值。类型为array：[\"1\",\"2\"]";
                }
                
                alertInputView.clickSendBtn = ^(NSString * _Nonnull content) {
                    
                    if (![weakSelf featureInputValidation:content featureItem:featureItem]) {
                        return;
                    }
                    
                    //功能点下发
                    if ([featureItem.type isEqualToString:@"boolean"]) {
                        featureItem.value = [NSNumber numberWithBool:[content boolValue]];
                    }
                    else if ([featureItem.type isEqualToString:@"integer"] ||
                             [featureItem.type isEqualToString:@"number"]) {
                        featureItem.value = [NSNumber numberWithInt:[content intValue]];
                    }
                    else if ([featureItem.type isEqualToString:@"object"] ||
                             [featureItem.type isEqualToString:@"array"]) {
                        
                        NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *err;
                        id value = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
                        featureItem.value = value;
                    }
                    else
                        featureItem.value = content;
                    
                    [weakSelf setFeatureValue:featureItem];
                    
                    [weakInputView removeFromSuperview];
                };
                [self.navigationController.view addSubview:alertInputView];
            }
        };
        
        return genericCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EZIoTFeatureItem *featureItem = self.featuresList[indexPath.row];
    [self performSegueWithIdentifier: @"ShowFeatureDetail" sender:featureItem];
}

#pragma mark - private

- (void)setFeatureValue:(EZIoTFeatureItem *)featureItem
{
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if ([featureItem isKindOfClass:[EZIoTPropertyFeatureItem class]])
    {
        [EZIoTDeviceManager setPropertyFeatureValuesWithItem:(EZIoTPropertyFeatureItem *)featureItem success:^{
                
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            NSLog(@"功能点下发成功: %@", featureItem.name);
            [weakSelf.navigationController.view makeToast:@"下发成功"  duration:3.0 position:CSToastPositionCenter];
            
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
    else
    {
        [EZIoTDeviceManager setActionFeatureValuesWithItem:(EZIoTActionFeatureItem *)featureItem success:^(NSDictionary * _Nullable deviceOutput) {
     
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            NSLog(@"功能点下发成功: %@", featureItem.name);
            [weakSelf.navigationController.view makeToast:[NSString stringWithFormat:@"下发成功，设备返回:%@", deviceOutput] duration:3.0 position:CSToastPositionCenter];
            
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[EZIoTDeviceFeatureDetailVC class]]) {
        EZIoTDeviceFeatureDetailVC *vc = segue.destinationViewController;
        vc.featureItem = sender;
    }
    else if([segue.destinationViewController isKindOfClass:[EZIoTDeviceSettingVC class]])
    {
        EZIoTDeviceSettingVC *vc = segue.destinationViewController;
        vc.deviceInfo = sender;
    }
}

- (Class)getFeatureItemCell:(EZIoTFeatureItem *)featureItem
{
    if ([featureItem.type isEqualToString:@"boolean"] && [featureItem isKindOfClass:[EZIoTPropertyFeatureItem class]])
    {
        return [EZIoTDeviceSwitchCell class];
    }
    else if (([featureItem.type isEqualToString:@"integer"] || [featureItem.type isEqualToString:@"number"])
               && [featureItem isKindOfClass:[EZIoTPropertyFeatureItem class]])
    {
        return [EZIoTDeviceProgressCell class];
    }
    else
    {
        return [EZIoTDeviceGenericCell class];
    }
}


-(NSString *)cellReusedIdentifier:(EZIoTFeatureItem *)featureItem{
    return NSStringFromClass([self getFeatureItemCell:featureItem]);
}

- (BOOL) featureInputValidation:(NSString *)input featureItem:(EZIoTFeatureItem *)featureItem
{
    if (input.length == 0) {
        [self.navigationController.view makeToast:@"输入不能为空"  duration:3.0 position:CSToastPositionCenter];
        return NO;
    }
    else if ([featureItem.type isEqualToString:@"boolean"]) {
        if (![self validateBool:input]) {
            [self.navigationController.view makeToast:@"输入格式有误"  duration:3.0 position:CSToastPositionCenter];
            return NO;
        }
    }
    else if ([featureItem.type isEqualToString:@"integer"] ||
             [featureItem.type isEqualToString:@"number"]) {
        if (![self validateNumber:input]) {
            [self.navigationController.view makeToast:@"输入格式有误"  duration:3.0 position:CSToastPositionCenter];
            return NO;
        }
    }
    else if ([featureItem.type isEqualToString:@"object"]) {
        
        NSData *jsonData = [input dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        id value = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        if (err || !value)
        {
            [self.navigationController.view makeToast:@"输入格式有误"  duration:3.0 position:CSToastPositionCenter];
            return NO;
        }
    }
    else if ([featureItem.type isEqualToString:@"array"]) {
        
        NSData *jsonData = [input dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        id value = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        if (err || !value)
        {
            [self.navigationController.view makeToast:@"输入格式有误"  duration:3.0 position:CSToastPositionCenter];
            return NO;
        }
    }
    return  YES;
}

- (BOOL)validateBool:(NSString *)textString
{
    NSString* number=@"0|1";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    return [numberPre evaluateWithObject:textString];
}


- (BOOL)validateNumber:(NSString *)textString
{
    NSString* number=@"^[0-9]+$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    return [numberPre evaluateWithObject:textString];
}

@end
