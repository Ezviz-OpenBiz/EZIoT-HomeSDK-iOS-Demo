//
//  EZIoTDeviceFeatureDetailVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/26.
//

#import "EZIoTDeviceFeatureDetailVC.h"

@interface EZIoTDeviceFeatureDetailVC ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceSNLabel;
@property (weak, nonatomic) IBOutlet UILabel *accessLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *keyLabel;
@property (weak, nonatomic) IBOutlet UILabel *localIndexLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UITextView *schemaTextView;

@end

@implementation EZIoTDeviceFeatureDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"功能点详情";
    
    self.nameLabel.text = self.featureItem.name?:@"none";
    self.deviceSNLabel.text = self.featureItem.deviceSerial?:@"none";
    self.typeLabel.text = self.featureItem.type?:@"none";
    self.keyLabel.text = self.featureItem.key?:@"none";
    self.localIndexLabel.text = self.featureItem.localIndex?:@"none";
    self.schemaTextView.text = self.featureItem.schema ? [NSString stringWithFormat:@"%@", self.featureItem.schema] : @"none";
    
    if ([self.featureItem isKindOfClass:[EZIoTPropertyFeatureItem class]])
    {
        EZIoTPropertyFeatureItem *pFeatureItem = (EZIoTPropertyFeatureItem *)self.featureItem;
        self.accessLabel.text = [self getAccessLabelText:pFeatureItem.access];
        self.valueLabel.text = [NSString stringWithFormat:@"%@", pFeatureItem.value ?: @"none"];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 6)
    {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Value" message:self.valueLabel.text preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:actionCancel];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

- (NSString *)getAccessLabelText:(NSString *)access
{
    if ([access isEqualToString:@"r"]) {
        return @"只读";
    }
    if ([access isEqualToString:@"rw"]) {
        return @"读写";
    }
    else {
        return @"none";
    }
}

@end
