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
#import "EditPeriodViewController.h"

static const CGFloat kHorizontalPadding = 20;
static const CGFloat kVerticalPadding = 10;

@interface TodayPeriodCollectionViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *taskName;
@property (nonatomic, assign) NSInteger periodIndex;

@property (nonatomic, strong) UILabel *taskNameLabel;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UILabel *totalLabel; // 总时长
@property (nonatomic, strong) UIDatePicker *startButton;
@property (nonatomic, strong) UILabel *dashLabel;
@property (nonatomic, strong) UIDatePicker *endButton;

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
        self.startButton.hidden = NO;
        self.endButton.hidden = NO;
        self.deleteButton.hidden = NO;
        long start = [task.periods[self.periodIndex][0] longValue];
        long end = [task.periods[self.periodIndex][1] longValue];
        self.totalLabel.text = [[MirrorLanguage mirror_stringWithKey:@"lasted"] stringByAppendingString:[[NSDateComponentsFormatter new] stringFromTimeInterval:[[NSDate dateWithTimeIntervalSince1970:end] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:start]]]];
        self.startButton.date = [NSDate dateWithTimeIntervalSince1970:start];
        self.endButton.date = [NSDate dateWithTimeIntervalSince1970:end];
    } else {
        self.startButton.hidden = YES;
        self.endButton.hidden = YES;
        self.deleteButton.hidden = YES;
        self.totalLabel.text = [MirrorLanguage mirror_stringWithKey:@"counting"];
        self.startButton.date = [NSDate now];
        self.endButton.date = [NSDate now];
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
    
    
    [self addSubview:self.startButton];
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-kVerticalPadding);
        make.left.offset(kHorizontalPadding);
        make.height.mas_equalTo((self.bounds.size.height - 2*kVerticalPadding)/2);
    }];
    [self addSubview:self.dashLabel];
    [self.dashLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-kVerticalPadding);
        make.left.mas_equalTo(self.startButton.mas_right);
        make.width.height.mas_equalTo((self.bounds.size.height - 2*kVerticalPadding)/2);
    }];
    [self addSubview:self.endButton];
    [self.endButton mas_makeConstraints:^(MASConstraintMaker *make) {
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

- (void)clickStartTime
{
    EditPeriodViewController *editVC = [[EditPeriodViewController alloc] initWithTaskname:self.taskName periodIndex:self.periodIndex isStartTime:YES];
    [self.delegate pushEditPeriodSheet:editVC];
}
- (void)clickEndTime
{
    EditPeriodViewController *editVC = [[EditPeriodViewController alloc] initWithTaskname:self.taskName periodIndex:self.periodIndex isStartTime:NO];
    [self.delegate pushEditPeriodSheet:editVC];
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


- (UIDatePicker *)startButton
{
    if (!_startButton) {
        _startButton = [UIDatePicker new];
        _startButton.datePickerMode = UIDatePickerModeTime;
        _startButton.timeZone = [NSTimeZone systemTimeZone];
        _startButton.preferredDatePickerStyle = UIDatePickerStyleCompact;
        _startButton.overrideUserInterfaceStyle = [MirrorSettings appliedDarkMode] ? UIUserInterfaceStyleDark:UIUserInterfaceStyleLight;
        _startButton.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_startButton addTarget:self action:@selector(clickStartTime) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
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

- (UIDatePicker *)endButton
{
    if (!_endButton) {
        _endButton = [UIDatePicker new];
        _endButton.datePickerMode = UIDatePickerModeTime;
        _endButton.timeZone = [NSTimeZone systemTimeZone];
        _endButton.preferredDatePickerStyle = UIDatePickerStyleCompact;
        _endButton.overrideUserInterfaceStyle = [MirrorSettings appliedDarkMode] ? UIUserInterfaceStyleDark:UIUserInterfaceStyleLight;
        _endButton.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_endButton addTarget:self action:@selector(clickStartTime) forControlEvents:UIControlEventTouchUpInside];
    }
    return _endButton;
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


@end
