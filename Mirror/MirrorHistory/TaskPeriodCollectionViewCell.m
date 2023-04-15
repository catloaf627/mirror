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

static const CGFloat kHorizontalPadding = 20;
static const CGFloat kVerticalPadding = 10;

@interface TaskPeriodCollectionViewCell ()

@property (nonatomic, strong) MirrorDataModel *task;
@property (nonatomic, assign) NSInteger periodIndex;

@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UILabel *mainLabel;
@property (nonatomic, strong) UILabel *detailLabel;

@end

@implementation TaskPeriodCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configWithTask:(MirrorDataModel *)task periodIndex:(NSInteger)index
{
    self.task = task;
    self.periodIndex = index;
    
    if ([self periodsIsFinished]) {
        long start = [task.periods[index][0] longValue];
        long end = [task.periods[index][1] longValue];
        self.mainLabel.text = [[MirrorLanguage mirror_stringWithKey:@"total"] stringByAppendingString:[[NSDateComponentsFormatter new] stringFromTimeInterval:[[NSDate dateWithTimeIntervalSince1970:end] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:start]]]];
        self.detailLabel.text = [[[self timeFromTimestamp:start] stringByAppendingString:@" - "]stringByAppendingString:[self timeFromTimestamp:end]];
    } else if (task.periods[index].count == 1) {
        self.mainLabel.text = [MirrorLanguage mirror_stringWithKey:@"counting"];
    }
    self.backgroundColor = [UIColor mirrorColorNamed:task.color];
    self.layer.cornerRadius = 14;
    [self p_setupUI];
}

- (void)p_setupUI
{
    [self addSubview:self.mainLabel];
    [self.mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(kVerticalPadding);
        make.left.offset(kHorizontalPadding);
        make.width.mas_equalTo(self.bounds.size.width - 3*kHorizontalPadding - 20);
        make.height.mas_equalTo((self.bounds.size.height - 2*kVerticalPadding)/2);
    }];
    [self addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-kVerticalPadding);
        make.left.offset(kHorizontalPadding);
        make.width.mas_equalTo(self.bounds.size.width - 3*kHorizontalPadding - 20);
        make.height.mas_equalTo((self.bounds.size.height - 2*kVerticalPadding)/2);
    }];
    if ([self periodsIsFinished]) {
        [self addSubview:self.deleteButton];
        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.offset(0);
            make.right.offset(-kHorizontalPadding);
            make.height.width.mas_equalTo(20);
        }];
    }
}

- (void)delete
{
    [MirrorStorage deletePeriodWithTaskname:self.task.taskName periodIndex:self.periodIndex];
}

- (BOOL)periodsIsFinished
{
    return self.task.periods[self.periodIndex].count == 2;
}

#pragma mark - Getters

- (UILabel *)mainLabel
{
    if (!_mainLabel) {
        _mainLabel = [UILabel new];
        _mainLabel.adjustsFontSizeToFitWidth = YES;
        _mainLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
    }
    return _mainLabel;
}

- (UILabel *)detailLabel
{
    if (!_detailLabel) {
        _detailLabel = [UILabel new];
        _detailLabel.adjustsFontSizeToFitWidth = YES;
        _detailLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
    }
    return _detailLabel;
}

- (UIButton *)deleteButton
{
    if (!_deleteButton) {
        _deleteButton = [UIButton new];
        UIImage *iconImage = [[UIImage systemImageNamed:@"delete.left"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_deleteButton setImage:[iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _deleteButton.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_deleteButton addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
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
