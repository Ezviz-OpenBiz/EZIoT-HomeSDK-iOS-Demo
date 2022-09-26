//
//  EZIoTRecordListVC.m
//  EZIoTHomeSDKDemo
//
//  Created by yuqian on 2021/12/1.
//

#import "EZIoTRecordListVC.h"
#import "EZIoTVideoPlayerVC.h"

#import <EZIoTIPCSDK/EZIoTDeviceRecordManger.h>
#import <EZIoTIPCSDK/EZIoTCloudRecordManager.h>
#import <EZIoTIPCSDK/EZIoTLocalFile.h>
#import <EZIoTIPCSDK/EZIoTCloudDayInfo.h>
#import <EZIoTIPCSDK/EZIoTCloudFile.h>

#import <FSCalendar/FSCalendar.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>
#import <EZIoTDeviceSDK/EZIoTDeviceSDK.h>


static NSString *reusedCellId = @"EZIoTRecordCell";

@interface EZIoTRecordListVC () <UITableViewDataSource,UITableViewDelegate,FSCalendarDataSource,FSCalendarDelegate,UIGestureRecognizerDelegate>
{
    void * _KVOContext;
}

@property (weak, nonatomic) IBOutlet FSCalendar *calendar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarHeightConstraint;

@property (strong, nonatomic) NSMutableArray *recordList;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) UIPanGestureRecognizer *scopeGesture;
@property (strong, nonatomic) NSMutableArray *datesWithEvent;

@end

@implementation EZIoTRecordListVC

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.recordType isEqualToString:@"Device"]) {
        self.title = @"设备录像";
        [self fetchDeviceRecords:[NSDate date]];
    }
    else{
        self.title = @"云录像";
        [self fetchCloudDayInfos];
    }
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.calendar action:@selector(handleScopeGesture:)];
    panGesture.delegate = self;
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 2;
    [self.view addGestureRecognizer:panGesture];
    self.scopeGesture = panGesture;
    [self.tableView.panGestureRecognizer requireGestureRecognizerToFail:panGesture];
    
    [self.calendar addObserver:self forKeyPath:@"scope" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:_KVOContext];
    self.calendar.placeholderType = FSCalendarPlaceholderTypeNone;
    self.calendar.scope = FSCalendarScopeMonth;
    self.calendar.backgroundColor = [UIColor whiteColor];
    
    [self.calendar selectDate:[NSDate date] scrollToDate:YES];
}

- (void) fetchDeviceRecords:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *beginTimeString = [NSString stringWithFormat:@"%@ 00:00:00", [dateFormatter stringFromDate:date]];
    NSString *endTimeString = [NSString stringWithFormat:@"%@ 23:59:59", [dateFormatter stringFromDate:date]];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSTimeInterval startTime = [[dateFormatter dateFromString:beginTimeString] timeIntervalSince1970];
    NSTimeInterval endTime = [[dateFormatter dateFromString:endTimeString] timeIntervalSince1970];
    
    [self fetchDeviceRecord:startTime endTime:endTime];
}

- (void) fetchCloudDayInfos
{
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EZIoTCloudRecordManager searchHasDaysFromCloud:self.deviceInfo.deviceSerial channelNo:self.deviceInfo.channelNumber success:^(NSArray<EZIoTCloudDayInfo *> * _Nonnull dayInfos) {
        
        weakSelf.datesWithEvent = [NSMutableArray array];
        for (EZIoTCloudDayInfo *dayInfo in dayInfos)
        {
            [weakSelf.datesWithEvent addObject:dayInfo.day];;
        }
        
        [weakSelf.calendar reloadData];
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        //search the last day cloud file
        if (weakSelf.datesWithEvent.count > 0)
        {
            [weakSelf fetchCloudDayInfo:weakSelf.datesWithEvent.lastObject];
        }
            
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"error: %@", error);
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:2.0 position:CSToastPositionCenter];
    }];
}

- (void) fetchDeviceRecord:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    [EZIoTDeviceRecordManger searchRecordsFromDevice:self.deviceInfo.deviceSerial channelNo:self.deviceInfo.channelNumber startTime:startTime stopTime:endTime size:100 success:^(NSArray<EZIoTLocalFile *> * _Nonnull localFiles) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        weakSelf.recordList = [NSMutableArray arrayWithArray:localFiles];
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        [weakSelf.recordList removeAllObjects];
        [weakSelf.tableView reloadData];
        
        NSLog(@"error: %@", error);
        if (error.code == 2004)
            [weakSelf.view makeToast:@"设备无录像"  duration:2.0 position:CSToastPositionCenter];
        else
            [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:2.0 position:CSToastPositionCenter];
    }];
}

- (void) fetchCloudDayInfo:(NSString *)dateStr
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    [EZIoTCloudRecordManager searchRecordsFromCloud:self.deviceInfo.deviceSerial channelNo:self.deviceInfo.channelNumber searchDate:dateStr success:^(NSArray<EZIoTCloudFile *> * _Nonnull cloudFiles) {
            
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        weakSelf.recordList = [NSMutableArray arrayWithArray:cloudFiles];
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        [weakSelf.recordList removeAllObjects];
        [weakSelf.tableView reloadData];
        
        NSLog(@"error: %@", error);
        [weakSelf.view makeToast:error.localizedFailureReason.length>0 ? error.localizedFailureReason : @"网络异常"  duration:3.0 position:CSToastPositionCenter];
    }];
}

- (void)dealloc
{
    [self.calendar removeObserver:self forKeyPath:@"scope" context:_KVOContext];
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context == _KVOContext) {
        FSCalendarScope oldScope = [change[NSKeyValueChangeOldKey] unsignedIntegerValue];
        FSCalendarScope newScope = [change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        NSLog(@"From %@ to %@",(oldScope==FSCalendarScopeWeek?@"week":@"month"),(newScope==FSCalendarScopeWeek?@"week":@"month"));
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top;
    if (shouldBegin) {
        CGPoint velocity = [self.scopeGesture velocityInView:self.view];
        switch (self.calendar.scope) {
            case FSCalendarScopeMonth:
                return velocity.y < 0;
            case FSCalendarScopeWeek:
                return velocity.y > 0;
        }
    }
    return shouldBegin;
}

#pragma mark - <FSCalendarDelegate>

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
//    NSLog(@"%@",(calendar.scope==FSCalendarScopeWeek?@"week":@"month"));
    _calendarHeightConstraint.constant = CGRectGetHeight(bounds);
    [self.view layoutIfNeeded];
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    NSString *selectDate = [self.dateFormatter stringFromDate:date];
    NSLog(@"did select date %@",[self.dateFormatter stringFromDate:date]);
    
    NSMutableArray *selectedDates = [NSMutableArray arrayWithCapacity:calendar.selectedDates.count];
    [calendar.selectedDates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [selectedDates addObject:[self.dateFormatter stringFromDate:obj]];
    }];
    NSLog(@"selected dates is %@",selectedDates);
    if (monthPosition == FSCalendarMonthPositionNext || monthPosition == FSCalendarMonthPositionPrevious) {
        [calendar setCurrentPage:date animated:YES];
    }
    
    if ([self.recordType isEqualToString:@"Device"]) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *beginTimeString = [NSString stringWithFormat:@"%@ 00:00:00", selectDate];
        NSString *endTimeString = [NSString stringWithFormat:@"%@ 23:59:59", selectDate];
        
        NSTimeInterval startTime = [[dateFormatter dateFromString:beginTimeString] timeIntervalSince1970];
        NSTimeInterval endTime = [[dateFormatter dateFromString:endTimeString] timeIntervalSince1970];
        
        [self fetchDeviceRecord:startTime endTime:endTime];
    }
    else{
        [self fetchCloudDayInfo:selectDate];
    }
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar
{
    NSLog(@"%s %@", __FUNCTION__, [self.dateFormatter stringFromDate:calendar.currentPage]);
}

#pragma mark - <FSCalendarDataSource>

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date
{
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    if ([_datesWithEvent containsObject:dateString]) {
        return 1;
    }
    return 0;
}

#pragma mark - Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recordList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellId forIndexPath:indexPath];
    
    if ([self.recordType isEqualToString:@"Device"])
    {
        EZIoTLocalFile *localFile = self.recordList[indexPath.row];
        
        NSString *beginTime = [localFile.beginTime componentsSeparatedByString:@"T"].lastObject;
        NSString *endTime = [localFile.endTime componentsSeparatedByString:@"T"].lastObject;
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@",  beginTime, endTime];
    }
    else
    {
        EZIoTCloudFile *cloudFile = self.recordList[indexPath.row];
        
//        NSString *beginTime = [cloudFile.startTime componentsSeparatedByString:@" "].lastObject;
//        NSString *endTime = [cloudFile.stopTime componentsSeparatedByString:@" "].lastObject;
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@",  cloudFile.startTime, cloudFile.stopTime];
    }
   
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"录像列表";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier: @"ShowPlayVC" sender:self.recordList[indexPath.row]];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    EZIoTVideoPlayerVC *vc = segue.destinationViewController;
    vc.deviceInfo = self.deviceInfo;
    
    if ([sender isKindOfClass:[EZIoTLocalFile class]])
    {
        vc.playeType = @"DevicePlayback";
        vc.localFile = sender;
    }
    else
    {
        vc.playeType = @"CloudPlayback";
        vc.cloudFile = sender;
    }
}


@end
