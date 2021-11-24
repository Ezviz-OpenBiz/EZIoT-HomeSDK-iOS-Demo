//
//  EZIoTDeviceListTypeVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/11/2.
//

#import "EZIoTDeviceListTypeVC.h"
#import "EZIoTDeviceListVC.h"

@interface EZIoTDeviceListTypeVC ()

@end

@implementation EZIoTDeviceListTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0)
        [self performSegueWithIdentifier: @"ShowDeviceListVC" sender:@"network"];
    else
        [self performSegueWithIdentifier: @"ShowDeviceListVC" sender:@"db"];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    EZIoTDeviceListVC *vc = segue.destinationViewController;
    vc.type = sender;
}


@end
