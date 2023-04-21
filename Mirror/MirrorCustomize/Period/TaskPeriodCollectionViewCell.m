//
//  TaskPeriodCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/15.
//

#import "TaskPeriodCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+MirrorColor.h"
#import "MirrorLanguage.h"
#import "MirrorStorage.h"
#import "EditPeriodViewController.h"

static const CGFloat kHorizontalPadding = 20;
static const CGFloat kVerticalPadding = 10;

@interface TaskPeriodCollectionViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *taskName;
@property (nonatomic, assign) NSInteger periodIndex;

@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UILabel *totalLabel; // 总时长
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *endButton;

@end

@implementation TaskPeriodCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configWithTaskname:(NSString *)taskName periodIndex:(NSInteger)index
{
    self.taskName = taskName;
    self.periodIndex = index;
    MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
    if ([self periodsIsFinished]) {
        long start = [task.periods[index][0] longValue];
        long end = [task.periods[index][1] longValue];
        self.totalLabel.text = [[MirrorLanguage mirror_stringWithKey:@"total"] stringByAppendingString:[[NSDateComponentsFormatter new] stringFromTimeInterval:[[NSDate dateWithTimeIntervalSince1970:end] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:start]]]];
        [self.startButton setTitle:[[self timeFromTimestamp:start] stringByAppendingString:@" -"] forState:UIControlStateNormal];
        [self.endButton setTitle:[@" " stringByAppendingString:[self timeFromTimestamp:end]] forState:UIControlStateNormal];
        self.startButton.hidden = NO;
        self.endButton.hidden = NO;
        self.deleteButton.hidden = NO;
    } else if (task.periods[index].count == 1) {
        self.totalLabel.text = [MirrorLanguage mirror_stringWithKey:@"counting"];
        self.startButton.hidden = YES;
        self.endButton.hidden = YES;
        self.deleteButton.hidden = YES;
    }
    self.backgroundColor = [UIColor mirrorColorNamed:task.color];
    self.layer.cornerRadius = 14;
    [self p_setupUI];
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
    if (![self periodsIsFinished]) return;
    [self addSubview:self.startButton];
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-kVerticalPadding);
        make.left.offset(kHorizontalPadding);
        make.width.mas_equalTo((self.bounds.size.width - 2*kHorizontalPadding)/2);
        make.height.mas_equalTo((self.bounds.size.height - 2*kVerticalPadding)/2);
    }];
    [self addSubview:self.endButton];
    [self.endButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-kVerticalPadding);
        make.right.offset(-kHorizontalPadding);
        make.width.mas_equalTo((self.bounds.size.width - 2*kHorizontalPadding)/2);
        make.height.mas_equalTo((self.bounds.size.height - 2*kVerticalPadding)/2);
    }];
    [self addSubview:self.deleteButton];
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.totalLabel);
        make.right.offset(-kHorizontalPadding);
        make.height.width.mas_equalTo(20);
    }];
}

- (BOOL)periodsIsFinished
{
    MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
    return task.periods[self.periodIndex].count == 2;
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
    }
    return _totalLabel;
}

- (UIButton *)startButton
{
    if (!_startButton) {
        _startButton = [UIButton new];
        _startButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_startButton setTitleColor:[UIColor mirrorColorNamed:MirrorColorTypeText] forState:UIControlStateNormal];
        [_startButton addTarget:self action:@selector(clickStartTime) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}

- (UIButton *)endButton
{
    if (!_endButton) {
        _endButton = [UIButton new];
        _endButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_endButton setTitleColor:[UIColor mirrorColorNamed:MirrorColorTypeText] forState:UIControlStateNormal];
        [_endButton addTarget:self action:@selector(clickEndTime) forControlEvents:UIControlEventTouchUpInside];
    }
    return _endButton;
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
