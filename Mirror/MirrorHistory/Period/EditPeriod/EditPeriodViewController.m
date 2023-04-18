//
//  EditPeriodViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/17.
//

#import "EditPeriodViewController.h"
#import "MirrorMacro.h"
#import "MirrorDataModel.h"
#import "MirrorStorage.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "MirrorLanguage.h"

static CGFloat const kEditPeriodVCPadding = 20;
static CGFloat const kHeightRatio = 0.8;

@interface EditPeriodViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSString *taskName;
@property (nonatomic, assign) NSInteger periodIndex;
@property (nonatomic, assign) BOOL isStartTime;

// UI
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIPickerView *secondPicker;
// 同cell上的展示
@property (nonatomic, strong) UILabel *totalLabel;
@property (nonatomic, strong) UILabel *detailLabel;

// seconds
@property (nonatomic, strong) NSArray *seconds;

@end

@implementation EditPeriodViewController

- (instancetype)initWithTaskname:(NSString *)taskName periodIndex:(NSInteger)periodIndex isStartTime:(BOOL)isStartTime
{
    self = [super init];
    if (self) {
        self.taskName = taskName;
        self.periodIndex = periodIndex;
        self.isStartTime = isStartTime;
        MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
        self.view.backgroundColor = [UIColor mirrorColorNamed:task.color];
        [self p_setupUI];
    }
    return self;
}

- (void)viewDidLayoutSubviews
{
    // 编辑task页面为半屏
    [self.view setFrame:CGRectMake(0, kScreenHeight*(1-kHeightRatio), kScreenWidth, kScreenHeight*kHeightRatio)];
    self.view.layer.cornerRadius = 20;
    self.view.layer.masksToBounds = YES;

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewGetsTapped:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.view.superview addGestureRecognizer:tapRecognizer];
}

- (void)p_setupUI
{
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kEditPeriodVCPadding);
        make.right.offset(-50 - 2*kEditPeriodVCPadding);
        make.top.offset(kEditPeriodVCPadding);
    }];
    [self.view addSubview:self.saveButton];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-kEditPeriodVCPadding);
        make.width.mas_equalTo(50);
        make.centerY.mas_equalTo(self.titleLabel);
        make.top.offset(kEditPeriodVCPadding);
    }];
    [self.view addSubview:self.datePicker];
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.right.offset(-60);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(kEditPeriodVCPadding);
    }];
    [self.view addSubview:self.secondPicker];
    [self.secondPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(0);
        make.centerY.mas_equalTo(self.datePicker);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(100);
    }];
    [self.view addSubview:self.totalLabel];
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.datePicker.mas_bottom).offset(kEditPeriodVCPadding);
        make.left.offset(kEditPeriodVCPadding);
        make.height.mas_equalTo(30);
    }];
    [self.view addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalLabel.mas_bottom).offset(kEditPeriodVCPadding);
        make.left.offset(kEditPeriodVCPadding);
        make.width.mas_equalTo(kScreenWidth - 2*kEditPeriodVCPadding);
    }];
    [self reloadLabels];
}

#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.seconds.count;
}


- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentJustified;
    style.firstLineHeadIndent = 10.0f;
    style.headIndent = 5;
    style.tailIndent = 5;
    NSString *text = [self.seconds[row] stringValue];
    NSAttributedString *attributedStr = [[NSAttributedString alloc]initWithString:text attributes:@{NSParagraphStyleAttributeName:style}];
    return attributedStr;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self reloadLabels];
}


#pragma mark - Actions
// 给superview添加了点击手势（为了在点击上方不属于self.view的地方可以dismiss掉self）
- (void)viewGetsTapped:(UIGestureRecognizer *)tapRecognizer
{
    CGPoint touchPoint = [tapRecognizer locationInView:self.view];
    if (touchPoint.y <= 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)saveButtonClicked
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *selects = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self.datePicker.date];
    selects.timeZone = [NSTimeZone systemTimeZone];
    selects.second = [self.seconds[[self.secondPicker selectedRowInComponent:0]] integerValue];
    NSDate *combinedDate = [gregorian dateFromComponents:selects];
    long timeStamp = [combinedDate timeIntervalSince1970];
    [MirrorStorage editPeriodIsStartTime:self.isStartTime to:timeStamp withTaskname:self.taskName periodIndex:self.periodIndex];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)reloadSecondsNLabels
{
    [self reloadSeconds]; // 调整年/月/日/时/分后，秒的范围会跟着变化
    [self reloadLabels]; // 调整年/月/日/时/分后，label会跟着变化
}

- (void)reloadSeconds
{
    // 先把之前选的second值取出来，不然修改self.seconds后再取就不对了。
    NSInteger selectedSecond = [self.seconds[[self.secondPicker selectedRowInComponent:0]] integerValue];
    // 设置都有哪些seconds值
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *selects = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self.datePicker.date];
    selects.timeZone = [NSTimeZone systemTimeZone];
    // maxs
    NSDateComponents *maxs = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[self maxDate]];
    maxs.timeZone = [NSTimeZone systemTimeZone];
    BOOL inTheSameMinutesWithMax = selects.year == maxs.year && selects.month == maxs.month && selects.day == maxs.day && selects.hour == maxs.hour && selects.minute == maxs.minute;
    // mins
    NSDateComponents *mins = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[self minDate]];
    mins.timeZone = [NSTimeZone systemTimeZone];
    BOOL inTheSameMinutesWithMin = selects.year == mins.year && selects.month == mins.month && selects.day == mins.day && selects.hour == mins.hour && selects.minute == mins.minute;
    if (inTheSameMinutesWithMax && inTheSameMinutesWithMin) { // 最大时间和最小时间narrow到只有秒数不同
        NSMutableArray *arr = [NSMutableArray new];
        for (NSInteger i=mins.second; i<=maxs.second; i++) {
            [arr addObject:@(i)];
        }
        self.seconds = [arr copy];
    } else if (inTheSameMinutesWithMax) { // 选择的年/月/日/时/分和最大值一样，那么最大值的秒数就是最大秒数
        NSMutableArray *arr = [NSMutableArray new];
        for (NSInteger i=0; i<=maxs.second; i++) {
            [arr addObject:@(i)];
        }
        self.seconds = [arr copy];
    } else if (inTheSameMinutesWithMin) { // 选择的年/月/日/时/分和最小值一样，那么最小值的秒数就是最小秒数
        NSMutableArray *arr = [NSMutableArray new];
        for (NSInteger i=mins.second; i<=59; i++) {
            [arr addObject:@(i)];
        }
        self.seconds = [arr copy];
    } else { // 选择的年/月/日/时/分 和最大、最小时间的年/月/日/时/分都不一样，秒数为完整的0-59
        NSMutableArray *arr = [NSMutableArray new];
        for (NSInteger i=0; i<=59; i++) {
            [arr addObject:@(i)];
        }
        self.seconds = [arr copy];
    }
    [self.secondPicker reloadAllComponents];
    
    // 设置选择第几个
    if (selectedSecond< [self.seconds[0] integerValue]) { // 选择的second比最小的还要小
        [self.secondPicker selectRow:0 inComponent:0 animated:YES];
        return;
    }
    if (selectedSecond > [self.seconds[self.seconds.count-1] integerValue]) { // 选择的second比最大的还要大
        [self.secondPicker selectRow:self.seconds.count-1 inComponent:0 animated:YES];
        return;
    }
    for (int i=0; i<self.seconds.count; i++) {
        if ([self.seconds[i] integerValue] == selectedSecond) {
            [self.secondPicker selectRow:i inComponent:0 animated:YES];
            return;
        }
    }
}

- (void)initSeconds
{
    // 设置都有哪些seconds值
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *selects = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self.datePicker.date];
    selects.timeZone = [NSTimeZone systemTimeZone];
    // maxs
    NSDateComponents *maxs = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[self maxDate]];
    maxs.timeZone = [NSTimeZone systemTimeZone];
    BOOL inTheSameMinutesWithMax = selects.year == maxs.year && selects.month == maxs.month && selects.day == maxs.day && selects.hour == maxs.hour && selects.minute == maxs.minute;
    // mins
    NSDateComponents *mins = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[self minDate]];
    mins.timeZone = [NSTimeZone systemTimeZone];
    BOOL inTheSameMinutesWithMin = selects.year == mins.year && selects.month == mins.month && selects.day == mins.day && selects.hour == mins.hour && selects.minute == mins.minute;
    if (inTheSameMinutesWithMax && inTheSameMinutesWithMin) { // 最大时间和最小时间narrow到只有秒数不同
        NSMutableArray *arr = [NSMutableArray new];
        for (NSInteger i=mins.second; i<=maxs.second; i++) {
            [arr addObject:@(i)];
        }
        self.seconds = [arr copy];
    } else if (inTheSameMinutesWithMax) { // 选择的年/月/日/时/分和最大值一样，那么最大值的秒数就是最大秒数
        NSMutableArray *arr = [NSMutableArray new];
        for (NSInteger i=0; i<=maxs.second; i++) {
            [arr addObject:@(i)];
        }
        self.seconds = [arr copy];
    } else if (inTheSameMinutesWithMin) { // 选择的年/月/日/时/分和最小值一样，那么最小值的秒数就是最小秒数
        NSMutableArray *arr = [NSMutableArray new];
        for (NSInteger i=mins.second; i<=59; i++) {
            [arr addObject:@(i)];
        }
        self.seconds = [arr copy];
    } else { // 选择的年/月/日/时/分 和最大、最小时间的年/月/日/时/分都不一样，秒数为完整的0-59
        NSMutableArray *arr = [NSMutableArray new];
        for (NSInteger i=0; i<=59; i++) {
            [arr addObject:@(i)];
        }
        self.seconds = [arr copy];
    }
    [self.secondPicker reloadAllComponents];
    
    // 设置选择第几个
    MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
    long initTime = [task.periods[self.periodIndex][self.isStartTime ? 0:1] longValue];
    NSDate *initDate = [NSDate dateWithTimeIntervalSince1970:initTime];
    NSDateComponents *inits = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:initDate];
    inits.timeZone = [NSTimeZone systemTimeZone];
    
    if (inits.second < [self.seconds[0] integerValue]) { // 初始second比最小的还要小
        [self.secondPicker selectRow:0 inComponent:0 animated:YES];
        return;
    }
    if (inits.second > [self.seconds[self.seconds.count-1] integerValue]) { // 初始second比最大的还要大
        [self.secondPicker selectRow:self.seconds.count-1 inComponent:0 animated:YES];
        return;
    }
    for (int i=0; i<self.seconds.count; i++) {
        if ([self.seconds[i] integerValue] == inits.second) {
            [self.secondPicker selectRow:i inComponent:0 animated:YES];
            return;
        }
    }
    
    
}

- (void)reloadLabels
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *selects = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self.datePicker.date];
    selects.timeZone = [NSTimeZone systemTimeZone];
    selects.second = [self.seconds[[self.secondPicker selectedRowInComponent:0]] integerValue];
    NSDate *combinedDate = [gregorian dateFromComponents:selects];
    long timeStamp = [combinedDate timeIntervalSince1970];
    if (self.isStartTime) {
        MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
        long start = timeStamp;
        long end = [task.periods[self.periodIndex][1] longValue];
        self.totalLabel.text = [[MirrorLanguage mirror_stringWithKey:@"total"] stringByAppendingString:[[NSDateComponentsFormatter new] stringFromTimeInterval:[[NSDate dateWithTimeIntervalSince1970:end] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:start]]]];
        self.detailLabel.text = [[[self timeFromTimestamp:start] stringByAppendingString:@" "] stringByAppendingString:[self timeFromTimestamp:end]];
    } else {
        MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
        long start = [task.periods[self.periodIndex][0] longValue];
        long end = timeStamp;
        self.totalLabel.text = [[MirrorLanguage mirror_stringWithKey:@"total"] stringByAppendingString:[[NSDateComponentsFormatter new] stringFromTimeInterval:[[NSDate dateWithTimeIntervalSince1970:end] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:start]]]];
        self.detailLabel.text = [[[self timeFromTimestamp:start] stringByAppendingString:@" "] stringByAppendingString:[self timeFromTimestamp:end]];
    }

}

#pragma mark - Getters

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.adjustsFontSizeToFitWidth = NO;
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
        NSInteger taskIndex = task.periods.count - self.periodIndex;
        if (self.isStartTime) {
            _titleLabel.text = [MirrorLanguage mirror_stringWithKey:@"start_time_for_period" with1Placeholder:[@(taskIndex) stringValue]];
        } else {
            _titleLabel.text = [MirrorLanguage mirror_stringWithKey:@"end_time_for_period" with1Placeholder:[@(taskIndex) stringValue]];
        }
        _titleLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
    }
    return _titleLabel;
}

- (UIButton *)saveButton
{
    if (!_saveButton) {
        _saveButton = [UIButton new];
        [_saveButton setTitle:[MirrorLanguage mirror_stringWithKey:@"save"] forState:UIControlStateNormal];
        [_saveButton addTarget:self action:@selector(saveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

- (UIDatePicker *)datePicker
{
    if (!_datePicker) {
        _datePicker = [UIDatePicker new];
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        _datePicker.timeZone = [NSTimeZone systemTimeZone];
        _datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
        _datePicker.tintColor = [UIColor mirrorColorNamed:[UIColor mirror_getPulseColorType:task.color]];
        long initTime = [task.periods[self.periodIndex][self.isStartTime ? 0:1] longValue];
        NSDate *initDate = [NSDate dateWithTimeIntervalSince1970:initTime];
        _datePicker.date = initDate;
        [_datePicker addTarget:self action:@selector(reloadSecondsNLabels) forControlEvents:UIControlEventValueChanged];
        _datePicker.maximumDate = [self maxDate];
        _datePicker.minimumDate = [self minDate];
    }
    return _datePicker;
}

- (NSDate *)maxDate
{
    MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
    long maxTime = 0;
    // 对于一个开始时间来说，它最小不能小于上一个task的结束时间（如果有上一个task的话），最大不能大于自己的结束时间
    if (self.isStartTime) {
        maxTime = [task.periods[self.periodIndex][1] longValue] - 1; // 至多比自己的结束时间小一秒
    }
    // 对于一个结束时间来说，它最小不能小于自己的开始时间，最大不能大于下一个task的开始时间（如果有下一个task的话）
    if (!self.isStartTime) {
        if (self.periodIndex-1 >= 0) { // 如果有下一个task的话
            NSArray *latterPeriod = task.periods[self.periodIndex-1];
            maxTime = [latterPeriod[0] longValue] - 1; // 至多也要比下一个task的开始时间小一秒
        } else {
            maxTime = NSIntegerMax;
        }
    }
    return [NSDate dateWithTimeIntervalSince1970:maxTime];
}

- (NSDate *)minDate
{
    MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
    long minTime = 0;
    // 对于一个开始时间来说，它最小不能小于上一个task的结束时间（如果有上一个task的话），最大不能大于自己的结束时间
    if (self.isStartTime) {
        if (self.periodIndex+1 < task.periods.count) { //如果有上一个task的话
            NSArray *formerPeriod = task.periods[self.periodIndex+1];
            minTime = [formerPeriod[1] longValue] + 1; // 至少比前一个task的结束时间多一秒
        } else {
            minTime = 0;
        }
    }
    // 对于一个结束时间来说，它最小不能小于自己的开始时间，最大不能大于下一个task的开始时间（如果有下一个task的话）
    if (!self.isStartTime) {
        minTime = [task.periods[self.periodIndex][0] longValue] + 1;// 至少比开始的时间多一秒
    }
    return [NSDate dateWithTimeIntervalSince1970:minTime];
}

- (UIPickerView *)secondPicker
{
    if (!_secondPicker) {
        _secondPicker = [UIPickerView new];
        _secondPicker.delegate = self;
        _secondPicker.dataSource = self;
        [self initSeconds];
    }
    return _secondPicker;
}

- (UILabel *)totalLabel
{
    if (!_totalLabel) {
        _totalLabel = [UILabel new];
        _totalLabel.adjustsFontSizeToFitWidth = YES;
        _totalLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
    }
    return _totalLabel;
}

- (UILabel *)detailLabel
{
    if (!_detailLabel) {
        _detailLabel = [UILabel new];
        _detailLabel.adjustsFontSizeToFitWidth = YES;
        _detailLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
    }
    return _detailLabel;
}

#pragma mark - Privates

- (NSString *)timeFromTimestamp:(long)timestamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    // setup
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    components.timeZone = [NSTimeZone systemTimeZone];
    // details
    long year = (long)components.year;
    long month = (long)components.month;
    long week = (long)components.weekday;
    long day = (long)components.day;
    long hour = (long)components.hour;
    long minute = (long)components.minute;
    long second = (long)components.second;
    // print
    NSString *weekday = @"unknow";
    if (week == 1) weekday = @"Sun";
    if (week == 2) weekday = @"Mon";
    if (week == 3) weekday = @"Tue";
    if (week == 4) weekday = @"Wed";
    if (week == 5) weekday = @"Thu";
    if (week == 6) weekday = @"Fri";
    if (week == 7) weekday = @"Sat";
    return [NSString stringWithFormat: @"%ld.%ld.%ld,%@,%ld:%ld:%ld", year, month, day, weekday, hour, minute, second];
}


@end
