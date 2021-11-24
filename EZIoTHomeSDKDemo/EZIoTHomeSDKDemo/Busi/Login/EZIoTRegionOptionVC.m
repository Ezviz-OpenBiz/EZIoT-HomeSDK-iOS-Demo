//
//  EZIoTRegionOptionVC.m
//  EZIoTSmartSDKDemo
//
//  Created by yuqian on 2021/9/29.
//

#import "EZIoTRegionOptionVC.h"
#import <EZIoTUserSDK/EZIoTUserSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>

static NSString *TableReusedID = @"TableReusedID";

@interface EZIoTRegionOptionVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *areaInfoList;  //所有区域列表
@property (nonatomic, strong) NSArray *sectionlist;   //索引列表
@property (nonatomic, strong) NSDictionary *sectionArealist;  //按索引归类后的区域列表
@property (nonatomic, strong) NSMutableArray *searchResultList;  //搜索结果列表
@property (nonatomic, strong) NSIndexPath *lastIndexPath;  //记录上一次选择的indexpath

@end

@implementation EZIoTRegionOptionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:TableReusedID];
    self.searchResultList = [NSMutableArray arrayWithCapacity:5];
    [self fetchAreaList];
}

- (void) fetchAreaList {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof(self) weakSelf = self;
    [EZIoTUserInfoManager getAreaListWithSuccess:^(NSArray<EZIoTUserAreaInfo *> * _Nonnull areaInfos) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        weakSelf.areaInfoList = [NSArray arrayWithArray:areaInfos];
        weakSelf.sectionArealist = [weakSelf trimAreaData:areaInfos];
        weakSelf.sectionlist = [weakSelf.sectionArealist.allKeys sortedArrayUsingSelector:@selector(localizedCompare:)];

        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        
        NSString *strErr = NSLocalizedString(@"user_common_tips_network_exception", @"网络异常");
        if (!error.localizedFailureReason) {
            strErr = [NSString stringWithFormat:NSLocalizedString(@"user_login_loginPage_server_exception_tips", @"服务器异常")];
        }
        [self.view makeToast:strErr duration:3.0 position:CSToastPositionCenter];
    }];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionlist.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSArray *areas = _sectionArealist[_sectionlist[section]];
    return areas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableReusedID forIndexPath:indexPath];
    NSArray *arr = _sectionArealist[_sectionlist[indexPath.section]];
    EZIoTUserAreaInfo *area = arr[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", area.name];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath != _lastIndexPath) {
        self.lastIndexPath = indexPath;
    }

    NSArray *arr = _sectionArealist[_sectionlist[indexPath.section]];
    EZIoTUserAreaInfo *area = arr[indexPath.row];

    [EZIoTUserInfoManager setAreaInfo:area];

    [self.view endEditing:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
   UIView *sectionHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
   sectionHeader.backgroundColor = UIColor.lightGrayColor;
   UILabel *sectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 200, 22)];
   sectionLabel.text = _sectionlist[section];
   sectionLabel.textAlignment = NSTextAlignmentLeft;
   sectionLabel.font = [UIFont boldSystemFontOfSize:16];
   
   [sectionHeader addSubview:sectionLabel];
   
   return sectionHeader;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return  30;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _sectionlist;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
   
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]
                     atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    return index;
}

#pragma mark private method

- (NSDictionary *) trimAreaData:(NSArray *)areaInfoList {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:5];
    
    for (EZIoTUserAreaInfo *areaInfo in areaInfoList)
    {
        NSMutableArray *arr = [dic objectForKey:areaInfo.index];
        if (arr.count > 0)
        {
            [arr addObject:areaInfo];
        }
        else
        {
            arr = [NSMutableArray arrayWithArray:@[areaInfo]];
        }
        [dic setValue:arr forKey:areaInfo.index];
    }
    return dic;
}


@end
