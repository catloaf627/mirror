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
#import "MirrorSettings.h"
#import "MirrorMacro.h"
#import "MirrorTimeText.h"

static const CGFloat kHorizontalPadding = 20;
static const CGFloat kVerticalPadding = 10;

@interface TaskPeriodCollectionViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *taskName;
@property (nonatomic, assign) NSInteger periodIndex;
@property (nonatomic, assign) BottomRightType type;

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UILabel *bottomRightLabel; // 总时长
@property (nonatomic, strong) UIDatePicker *startPicker;
@property (nonatomic, strong) UILabel *dashLabel;
@property (nonatomic, strong) UIDatePicker *endPicker;

@end

@implementation TaskPeriodCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configWithTaskname:(NSString *)taskName periodIndex:(NSInteger)index type:(BottomRightType)type
{
    self.taskName = taskName;
    self.periodIndex = index;
    self.type = type;
    [self updateCellInfo];
    self.layer.cornerRadius = 14;
    [self p_setupUI];
}

- (void)updateCellInfo
{
    MirrorTaskModel *task = [MirrorStorage getTaskModelFromDB:self.taskName];
    NSMutableArray<MirrorRecordModel *> *allRecords = [MirrorStorage retriveMirrorRecords];
    self.backgroundColor = [UIColor mirrorColorNamed:task.color];
    NSString *prefix =  [MirrorSettings appliedShowIndex] ? [[@"No." stringByAppendingString:[@(self.periodIndex) stringValue]] stringByAppendingString:@" "] : @"";
    self.dateLabel.text = [prefix stringByAppendingString:[MirrorTimeText YYYYmmddWeekdayWithStart:allRecords[self.periodIndex].startTime]];
    long start = allRecords[self.periodIndex].startTime;
    long end =  allRecords[self.periodIndex].endTime;
    if (self.type == BottomRightTypeTotal) {
        self.bottomRightLabel.text = [MirrorTimeText XdXhXmXsShortWithstart:start end:end];
    } else {
        self.bottomRightLabel.text = self.taskName;
    }

    self.startPicker.date = [NSDate dateWithTimeIntervalSince1970:start];
    self.startPicker.maximumDate = [self startMaxDate];
    self.startPicker.minimumDate = [self startMinDate];
    self.endPicker.date = [NSDate dateWithTimeIntervalSince1970:end];
    self.endPicker.maximumDate = [self endMaxDate];
    self.endPicker.minimumDate = [self endMinDate];
}

- (void)p_setupUI
{
    [self addSubview:self.dateLabel];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(kVerticalPadding);
        make.left.offset(kHorizontalPadding);
        make.width.mas_equalTo(self.bounds.size.width - 3*kHorizontalPadding - 20);
        make.height.mas_equalTo((self.bounds.size.height - 2*kVerticalPadding)/2);
    }];
    [self addSubview:self.deleteButton];
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.dateLabel);
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
    [self addSubview:self.bottomRightLabel];
    [self.bottomRightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-kVerticalPadding);
        make.right.offset(-kHorizontalPadding);
        make.height.mas_equalTo((self.bounds.size.height - 2*kVerticalPadding)/2);
    }];

}

#pragma mark - Actions

- (void)changeStartTime
{
    long startTime = [self.startPicker.date timeIntervalSince1970];
    [MirrorStorage editPeriodIsStartTime:YES to:startTime periodIndex:self.periodIndex];
    [self updateCellInfo];
}
- (void)changeEndTime
{
    long endTime = [self.endPicker.date timeIntervalSince1970];
    [MirrorStorage editPeriodIsStartTime:NO to:endTime periodIndex:self.periodIndex];
    [self updateCellInfo];
}

- (void)deletePeriod
{
    UIAlertController* deleteButtonAlert = [UIAlertController alertControllerWithTitle:[MirrorLanguage mirror_stringWithKey:@"delete_period_?"] message:nil preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:[MirrorLanguage mirror_stringWithKey:@"delete"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [MirrorStorage deletePeriodAtIndex:self.periodIndex];
        [self.delegate updateUIAfterDeleteDataAtIndex:self.periodIndex];
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:[MirrorLanguage mirror_stringWithKey:@"cancel"] style:UIAlertActionStyleDefault handler:nil];

    [deleteButtonAlert addAction:cancelAction];
    [deleteButtonAlert addAction:deleteAction];
    [self.delegate presentViewController:deleteButtonAlert animated:YES completion:nil];
}

#pragma mark - Getters

- (UILabel *)bottomRightLabel
{
    if (!_bottomRightLabel) {
        _bottomRightLabel = [UILabel new];
        _bottomRightLabel.adjustsFontSizeToFitWidth = YES;
        _bottomRightLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _bottomRightLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:12];
    }
    return _bottomRightLabel;
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
        _startPicker.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_startPicker addTarget:self action:@selector(changeStartTime) forControlEvents:UIControlEventEditingDidEnd];
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
        _endPicker.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_endPicker addTarget:self action:@selector(changeEndTime) forControlEvents:UIControlEventEditingDidEnd];
    }
    return _endPicker;
}

- (UILabel *)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [UILabel new];
        _dateLabel.adjustsFontSizeToFitWidth = YES;
        _dateLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _dateLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:17];
    }
    return _dateLabel;
}


#pragma mark - Privates

- (NSDate *)startMaxDate
{
    MirrorRecordModel *record = [MirrorStorage retriveMirrorRecords][self.periodIndex];
    long maxTime = 0;
    // 对于一个开始时间来说，最大不能大于自己的结束时间-kMinSeconds
    maxTime = record.endTime - kMinSeconds; // 至多比自己的结束时间小一分钟
    return [NSDate dateWithTimeIntervalSince1970:maxTime];
}

- (NSDate *)endMaxDate
{
    long maxTime = 0;
    // 对于一个结束时间来说，最大不能大于下一个task的开始时间（如果有下一个task的话）
    if (self.periodIndex+1 <= [MirrorStorage retriveMirrorRecords].count-1) { // 如果有下一个task的话
        MirrorRecordModel *nextRecord = [MirrorStorage retriveMirrorRecords][self.periodIndex+1];
        maxTime = nextRecord.startTime; // 至多也要等于下一个task的开始时间
    } else {
        maxTime = LONG_MAX;
    }
    return [NSDate dateWithTimeIntervalSince1970:maxTime];
}


- (NSDate *)startMinDate
{
    long minTime = 0;
    // 对于一个开始时间来说，它最小不能小于上一个task的结束时间（如果有上一个task的话
    if (self.periodIndex-1 >= 0) { //如果有上一个task的话
        MirrorRecordModel *formmerRecord = [MirrorStorage retriveMirrorRecords][self.periodIndex-1];
        minTime = formmerRecord.endTime; // 至少等于前一个task的结束时间
    } else {
        minTime = 0;
    }

    return [NSDate dateWithTimeIntervalSince1970:minTime];
}

- (NSDate *)endMinDate
{
    MirrorRecordModel *record = [MirrorStorage retriveMirrorRecords][self.periodIndex];
    long minTime = 0;
    // 对于一个结束时间来说，它最小不能小于自己的开始时间+kMinSeconds
    minTime = record.startTime + kMinSeconds;// 至少比开始的时间多一分钟
    return [NSDate dateWithTimeIntervalSince1970:minTime];
}



@end
