//
//  EZIoTMsgListVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/10/21.
//

#import "EZIoTMsgListVC.h"
#import <EZIoTMessageSDK/EZIoTMessageSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <MJRefresh/MJRefresh.h>
#import "EZIoTMsgDetailVC.h"


#define Request_Data_Limit  10

static NSString *reuseIdentifier = @"EZIoTMsgListCell";

@interface EZIoTMsgListVC ()

@property (nonatomic, strong) NSMutableArray <EZIoTMsgInfo *>*msgsList;
@property (nonatomic, strong) EZIoTMsgListResp *resp;

@end

@implementation EZIoTMsgListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.itemTitle;
    
    __weak typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf requestDatas:YES];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        if (!self.resp.hasNext) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            return;
        }
        [weakSelf requestDatas:NO];
    }];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void) requestDatas:(BOOL)isRefresh
{
    __weak typeof(self) weakSelf = self;
    [EZIoTMessageManager getMessageListWithSubTypes:self.subTypes limit:Request_Data_Limit endTime:isRefresh?@"0":self.resp.timestamp date:@"" success:^(EZIoTMsgListResp * _Nonnull resp) {
        
        if (isRefresh) {
            weakSelf.msgsList = [NSMutableArray arrayWithArray:resp.msgInfos];
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer resetNoMoreData];
            weakSelf.tableView.mj_header.hidden = YES;
            if (!resp || resp.msgInfos.count == 0) {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                return;
            }
        }
        else
        {
            [weakSelf.msgsList addObjectsFromArray:resp.msgInfos];
            [weakSelf.tableView.mj_footer endRefreshing];
        }
        
        if (!resp.hasNext) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        
        weakSelf.resp = resp;
        NSLog(@"resp.msgInfos: %@", resp.msgInfos);
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        isRefresh ? [weakSelf.tableView.mj_header endRefreshing] : [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    EZIoTMsgDetailVC *vc = segue.destinationViewController;
    vc.msgInfo = sender;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.prefersLargeTitles = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.prefersLargeTitles = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.msgsList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    EZIoTMsgInfo *msg = self.msgsList[indexPath.row];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:msg.pic?:msg.defaultPic] placeholderImage:[UIImage imageNamed:@"msgIcon"]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.textLabel.text = msg.title;
    cell.detailTextLabel.text = msg.timeStr;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier: @"ShowMsgDetail" sender:self.msgsList[indexPath.row]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    CGPoint point=scrollView.contentOffset;
    if (point.y < -150) {
        self.tableView.mj_header.hidden = NO;
    }
}

@end
