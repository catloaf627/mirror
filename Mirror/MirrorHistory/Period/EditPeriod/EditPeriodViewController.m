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
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIPickerView *secondPicker;

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
    [self.view addSubview:self.hintLabel];
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kEditPeriodVCPadding);
        make.right.offset(-50 - 2*kEditPeriodVCPadding);
        make.top.offset(kEditPeriodVCPadding);
    }];
    [self.view addSubview:self.saveButton];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-kEditPeriodVCPadding);
        make.width.mas_equalTo(50);
        make.centerY.mas_equalTo(self.hintLabel);
        make.top.offset(kEditPeriodVCPadding);
    }];
    [self.view addSubview:self.datePicker];
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.right.offset(-60);
        make.top.mas_equalTo(self.hintLabel.mas_bottom).offset(kEditPeriodVCPadding);
    }];
    [self.view addSubview:self.secondPicker];
    [self.secondPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(0);
        make.centerY.mas_equalTo(self.datePicker);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(100);
    }];
}

#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 60;
}


- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentJustified;
    style.firstLineHeadIndent = 10.0f;
    style.headIndent = 5;
    style.tailIndent = 5;
    NSString *text = [@(row+1) stringValue];
    NSAttributedString *attributedStr = [[NSAttributedString alloc]initWithString:text attributes:@{NSParagraphStyleAttributeName:style}];
    return attributedStr;
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
    
}

- (void)selectDatePick
{
    NSLog(@"gizmo %@", self.datePicker.date); // 在这里更新second picker
}

#pragma mark - Getters

- (UILabel *)hintLabel
{
    if (!_hintLabel) {
        _hintLabel = [UILabel new];
        _hintLabel.adjustsFontSizeToFitWidth = NO;
        _hintLabel.numberOfLines = 0;
        _hintLabel.textAlignment = NSTextAlignmentCenter;
        MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
        NSInteger taskIndex = task.periods.count - self.periodIndex;
        if (self.isStartTime) {
            _hintLabel.text = [MirrorLanguage mirror_stringWithKey:@"start_time_for_period" with1Placeholder:[@(taskIndex) stringValue]];
        } else {
            _hintLabel.text = [MirrorLanguage mirror_stringWithKey:@"end_time_for_period" with1Placeholder:[@(taskIndex) stringValue]];
        }
        _hintLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
    }
    return _hintLabel;
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
        [_datePicker addTarget:self action:@selector(selectDatePick) forControlEvents:UIControlEventValueChanged];
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
        MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
        long initTime = [task.periods[self.periodIndex][self.isStartTime ? 0:1] longValue];
        NSDate *initDate = [NSDate dateWithTimeIntervalSince1970:initTime];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:initDate];
        components.timeZone = [NSTimeZone systemTimeZone];
        NSInteger rowIndex = components.second-1;
        [_secondPicker selectRow:rowIndex inComponent:0 animated:YES];
    }
    return _secondPicker;
}


@end
