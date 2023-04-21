//
//  TodayPeriodCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/21.
//

#import "TodayPeriodCollectionViewCell.h"
#import "MirrorSettings.h"
#import <Masonry/Masonry.h>
#import "UIColor+MirrorColor.h"
#import "MirrorLanguage.h"
#import "MirrorStorage.h"

static const CGFloat kHorizontalPadding = 20;
static const CGFloat kVerticalPadding = 10;

@interface TodayPeriodCollectionViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *taskName;
@property (nonatomic, assign) NSInteger periodIndex;

@property (nonatomic, strong) UILabel *taskNameLabel;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UILabel *totalLabel; // 总时长
@property (nonatomic, strong) UIDatePicker *startPicker;
@property (nonatomic, strong) UILabel *dashLabel;
@property (nonatomic, strong) UIDatePicker *endPicker;

@end

@implementation TodayPeriodCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configWithTaskname:(NSString *)taskName periodIndex:(NSInteger)index
{
    self.taskName = taskName;
    self.periodIndex = index;
    [self updateCellInfo];
    self.layer.cornerRadius = 14;
    [self p_setupUI];
}

- (void)updateCellInfo
{
    MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
    self.backgroundColor = [UIColor mirrorColorNamed:task.color];
    BOOL periodsIsFinished = task.periods[self.periodIndex].count == 2;
    self.taskNameLabel.text = self.taskName;
    if (periodsIsFinished) {
        self.startPicker.hidden = NO;
        self.endPicker.hidden = NO;
        self.dashLabel.hidden = NO;
        self.deleteButton.hidden = NO;
        long start = [task.periods[self.periodIndex][0] longValue];
        long end = [task.periods[self.periodIndex][1] longValue];
        self.totalLabel.text = [[MirrorLanguage mirror_stringWithKey:@"lasted"] stringByAppendingString:[[NSDateComponentsFormatter new] stringFromTimeInterval:[[NSDate dateWithTimeIntervalSince1970:end] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:start]]]];
        self.startPicker.date = [NSDate dateWithTimeIntervalSince1970:start];
        self.startPicker.maximumDate = [self startMaxDate];
        self.startPicker.minimumDate = [self startMinDate];
        self.endPicker.date = [NSDate dateWithTimeIntervalSince1970:end];
        self.endPicker.maximumDate = [self endMaxDate];
        self.endPicker.minimumDate = [self endMinDate];
    } else {
        self.startPicker.hidden = YES;
        self.endPicker.hidden = YES;
        self.dashLabel.hidden = YES;
        self.deleteButton.hidden = YES;
        self.totalLabel.text = [MirrorLanguage mirror_stringWithKey:@"counting"];
    }
}

- (void)p_setupUI
{
    [self addSubview:self.totalLabel];
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(kVerticalPadding);
        make.left.offset(kHorizontalPadding);
        make.width.mas_equalTo(self.bounds.size.width - 3*kHorizontalPadding - 20);
        make.height.mas_equalTo((self.bounds.size.height - 2*kVerticalPadding)/2);
    }];
    [self addSubview:self.deleteButton];
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.totalLabel);
        make.right.offset(-kHorizontalPadding);
        make.height.width.mas_equalTo(20);
    }];
    
    
    [self addSubview:self.startPicker];
    [self.startPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-kVerticalPadding);
        make.left.offset(kHorizontalPadding);
        make.height.mas_equalTo((self.bounds.size.height - 2*kVerticalPadding)/2);
    }];
    [self addSubview:self.dashLabel];
    [self.dashLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-kVerticalPadding);
        make.left.mas_equalTo(self.startPicker.mas_right);
        make.width.height.mas_equalTo((self.bounds.size.height - 2*kVerticalPadding)/2);
    }];
    [self addSubview:self.endPicker];
    [self.endPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-kVerticalPadding);
        make.left.mas_equalTo(self.dashLabel.mas_right);
        make.height.mas_equalTo((self.bounds.size.height - 2*kVerticalPadding)/2);
    }];
    [self addSubview:self.taskNameLabel];
    [self.taskNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-kVerticalPadding);
        make.right.offset(-kHorizontalPadding);
        make.height.mas_equalTo((self.bounds.size.height - 2*kVerticalPadding)/2);
    }];

}

#pragma mark - Actions

- (void)changeStartTime
{
    long startTime = [self.startPicker.date timeIntervalSince1970];
    [MirrorStorage editPeriodIsStartTime:YES to:startTime withTaskname:self.taskName periodIndex:self.periodIndex];
    [self updateCellInfo];
}
- (void)changeEndTime
{
    long endTime = [self.startPicker.date timeIntervalSince1970];
    [MirrorStorage editPeriodIsStartTime:NO to:endTime withTaskname:self.taskName periodIndex:self.periodIndex];
    [self updateCellInfo];
}

- (void)deletePeriod
{
    UIAlertController* deleteButtonAlert = [UIAlertController alertControllerWithTitle:[MirrorLanguage mirror_stringWithKey:@"delete_period_?"] message:nil preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:[MirrorLanguage mirror_stringWithKey:@"delete"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [MirrorStorage deletePeriodWithTaskname:self.taskName periodIndex:self.periodIndex];
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:[MirrorLanguage mirror_stringWithKey:@"cancel"] style:UIAlertActionStyleDefault handler:nil];

    [deleteButtonAlert addAction:deleteAction];
    [deleteButtonAlert addAction:cancelAction];
    [self.delegate presentViewController:deleteButtonAlert animated:YES completion:nil];
}

#pragma mark - Getters

- (UILabel *)totalLabel
{
    if (!_totalLabel) {
        _totalLabel = [UILabel new];
        _totalLabel.adjustsFontSizeToFitWidth = YES;
        _totalLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _totalLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:17];
    }
    return _totalLabel;
}


- (UIButton *)deleteButton
{
    if (!_deleteButton) {
        _deleteButton = [UIButton new];
        UIImage *iconImage = [[UIImage systemImageNamed:@"delete.left"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_deleteButton setImage:[iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _deleteButton.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_deleteButton addTarget:self action:@selector(deletePeriod) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}


- (UIDatePicker *)startPicker
{
    if (!_startPicker) {
        _startPicker = [UIDatePicker new];
        _startPicker.datePickerMode = UIDatePickerModeTime;
        _startPicker.timeZone = [NSTimeZone systemTimeZone];
        _startPicker.preferredDatePickerStyle = UIDatePickerStyleCompact;
        _startPicker.overrideUserInterfaceStyle = [MirrorSettings appliedDarkMode] ? UIUserInterfaceStyleDark:UIUserInterfaceStyleLight;
        _startPicker.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_startPicker addTarget:self action:@selector(changeStartTime) forControlEvents:UIControlEventValueChanged];
    }
    return _startPicker;
}

- (UILabel *)dashLabel
{
    if (!_dashLabel) {
        _dashLabel = [UILabel new];
        _dashLabel.text = @"-";
        _dashLabel.textAlignment = NSTextAlignmentCenter;
        _dashLabel.adjustsFontSizeToFitWidth = YES;
        _dashLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
    }
    return _dashLabel;
}

- (UIDatePicker *)endPicker
{
    if (!_endPicker) {
        _endPicker = [UIDatePicker new];
        _endPicker.datePickerMode = UIDatePickerModeTime;
        _endPicker.timeZone = [NSTimeZone systemTimeZone];
        _endPicker.preferredDatePickerStyle = UIDatePickerStyleCompact;
        _endPicker.overrideUserInterfaceStyle = [MirrorSettings appliedDarkMode] ? UIUserInterfaceStyleDark:UIUserInterfaceStyleLight;
        _endPicker.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_endPicker addTarget:self action:@selector(changeEndTime) forControlEvents:UIControlEventValueChanged];
    }
    return _endPicker;
}

- (UILabel *)taskNameLabel
{
    if (!_taskNameLabel) {
        _taskNameLabel = [UILabel new];
        _taskNameLabel.adjustsFontSizeToFitWidth = YES;
        _taskNameLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _taskNameLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:12];
    }
    return _taskNameLabel;
}


#pragma mark - Privates

- (NSString *)timeFromTimestamp:(long)timestamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    // setup
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    components.timeZone = [NSTimeZone systemTimeZone];
    // details
    long hour = (long)components.hour;
    long minute = (long)components.minute;
    long second = (long)components.second;

    return [NSString stringWithFormat: @"%ld:%ld:%ld", hour, minute, second];
}

- (NSDate *)startMaxDate
{
    MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
    long maxTime = 0;
    // 对于一个开始时间来说，它最小不能小于上一个task的结束时间（如果有上一个task的话），最大不能大于自己的结束时间
    maxTime = [task.periods[self.periodIndex][1] longValue] - 1; // 至多比自己的结束时间小一秒
    return [NSDate dateWithTimeIntervalSince1970:maxTime];
}

- (NSDate *)endMaxDate
{
    MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
    long maxTime = 0;
    // 对于一个结束时间来说，它最小不能小于自己的开始时间，最大不能大于下一个task的开始时间（如果有下一个task的话）
    if (self.periodIndex-1 >= 0) { // 如果有下一个task的话
        NSArray *latterPeriod = task.periods[self.periodIndex-1];
        maxTime = [latterPeriod[0] longValue] - 1; // 至多也要比下一个task的开始时间小一秒
    } else {
        maxTime = [[NSDate now] timeIntervalSince1970];
    }
    return [NSDate dateWithTimeIntervalSince1970:maxTime];
}


- (NSDate *)startMinDate
{
    MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
    long minTime = 0;
    // 对于一个开始时间来说，它最小不能小于上一个task的结束时间（如果有上一个task的话），最大不能大于自己的结束时间
    if (self.periodIndex+1 < task.periods.count) { //如果有上一个task的话
        NSArray *formerPeriod = task.periods[self.periodIndex+1];
        minTime = [formerPeriod[1] longValue] + 1; // 至少比前一个task的结束时间多一秒
    } else {
        minTime = 0;
    }

    return [NSDate dateWithTimeIntervalSince1970:minTime];
}

- (NSDate *)endMinDate
{
    MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
    long minTime = 0;
    // 对于一个结束时间来说，它最小不能小于自己的开始时间，最大不能大于下一个task的开始时间（如果有下一个task的话）
    minTime = [task.periods[self.periodIndex][0] longValue] + 1;// 至少比开始的时间多一秒
    return [NSDate dateWithTimeIntervalSince1970:minTime];
}


@end
