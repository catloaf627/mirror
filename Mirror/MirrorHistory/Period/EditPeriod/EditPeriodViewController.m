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

// 对于一个开始时间来说，它最小不能小于上一个task的结束时间（如果有上一个task的话），最大不能大于自己的结束时间
// 对于一个结束时间来说，它最小不能小于自己的开始时间，最大不能大于下一个task的开始时间（如果有下一个task的话）
@property (nonatomic, assign) long minTime;
@property (nonatomic, assign) long maxTime;

// UI
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIView *secondView;
@property (nonatomic, strong) UILabel *secondLabel;
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
        make.left.offset(kEditPeriodVCPadding);
        make.right.offset(-kEditPeriodVCPadding);
        make.top.mas_equalTo(self.hintLabel.mas_bottom).offset(kEditPeriodVCPadding);
    }];
    [self.view addSubview:self.secondView];
    [self.secondView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.datePicker.mas_bottom);
        make.centerX.offset(0);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(100);
    }];
    
    [self.secondView addSubview:self.secondPicker];
    [self.secondPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.left.offset(0);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(100);
    }];
    [self.secondView addSubview:self.secondLabel];
    [self.secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.right.offset(0);
        make.width.mas_equalTo(10);
        make.height.mas_equalTo(100);
    }];
}

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
    }
    return _saveButton;
}

- (UIDatePicker *)datePicker
{
    if (!_datePicker) {
        _datePicker = [UIDatePicker new];
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        _datePicker.timeZone = [NSTimeZone systemTimeZone];
        _datePicker.preferredDatePickerStyle = UIDatePickerStyleInline;
        MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
        _datePicker.tintColor = [UIColor mirrorColorNamed:[UIColor mirror_getPulseColorType:task.color]];
        long initTime = [task.periods[self.periodIndex][self.isStartTime ? 0:1] longValue];
        NSDate *initDate = [NSDate dateWithTimeIntervalSince1970:initTime];
        _datePicker.date = initDate;
    }
    return _datePicker;
}

- (UIView *)secondView
{
    if (!_secondView) {
        _secondView = [UIView new];
    }
    return _secondView;
}

- (UILabel *)secondLabel
{
    if (!_secondLabel) {
        _secondLabel = [UILabel new];
        _secondLabel.adjustsFontSizeToFitWidth = NO;
        _secondLabel.numberOfLines = 1;
        _secondLabel.textAlignment = NSTextAlignmentCenter;
        _secondLabel.text = @"s";
        _secondLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
        _secondLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
    }
    return _secondLabel;
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
