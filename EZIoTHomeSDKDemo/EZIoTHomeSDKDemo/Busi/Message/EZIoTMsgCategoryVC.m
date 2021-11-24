//
//  EZIoTMsgCategoryVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/20.
//

#import "EZIoTMsgCategoryVC.h"
#import <EZIoTMessageSDK/EZIoTMessageSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "EZIoTMsgListVC.h"


static NSString *reuseIdentifier = @"EZIoTMsgCategoryCell";

@interface EZIoTMsgCategoryVC ()

@property (nonatomic, strong) NSArray<EZIoTMsgCategoryInfo *> *msgCategories;

@end

@implementation EZIoTMsgCategoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTMessageManager getMessageCategoriesWithSuccess:^(NSArray<EZIoTMsgCategoryInfo *> * _Nonnull msgCategories) {
           
        weakSelf.msgCategories = msgCategories;
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"msgCategories: %@", msgCategories);
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        
        NSLog(@"error: %@", error);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    EZIoTMsgCategoryInfo *info = sender;
    EZIoTMsgListVC *vc = segue.destinationViewController;
    vc.itemTitle = info.name;
    vc.subTypes = info.subTypes;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.msgCategories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    EZIoTMsgCategoryInfo *info = self.msgCategories[indexPath.row];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:info.pic2x] placeholderImage:[UIImage imageNamed:@"msgIcon"]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.textLabel.text = info.name;
    cell.detailTextLabel.text = @"";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier: @"ShowMsgList" sender:self.msgCategories[indexPath.row]];
}

@end
