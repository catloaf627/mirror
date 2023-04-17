//
//  TimeTrackingView.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/10/22.
//

#import "TimeTrackingView.h"
#import "MirrorDataModel.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "MirrorMacro.h"
#import "MirrorLanguage.h"
#import "MirrorStorage.h"
#import "MirrorTool.h"

static CGFloat const kPadding = 20;

static CGFloat const kTaskNameSize = 35;
static CGFloat const kIntervalSize = 70;
static CGFloat const kHintSize = 25;

static NSString *const kHintFont = @"TrebuchetMS-Italic";
static CGFloat const kTimeSpacing = 5;
static CGFloat const kDashSpacing = 10;

@interface TimeTrackingView ()

// UI
@property (nonatomic, strong) UILabel *taskNameLabel;

@property (nonatomic, strong) UILabel *timeIntervalLabel;

@property (nonatomic, strong) UILabel *startTimeLabelHH;
@property (nonatomic, strong) UILabel *startTimeColonLabelA;
@property (nonatomic, strong) UILabel *startTimeLabelmm;
@property (nonatomic, strong) UILabel *startTimeColonLabelB;
@property (nonatomic, strong) UILabel *startTimeLabelss;

@property (nonatomic, strong) UILabel *dashLabel;

@property (nonatomic, strong) UILabel *nowTimeLabelHH;
@property (nonatomic, strong) UILabel *nowTimeColonLabelA;
@property (nonatomic, strong) UILabel *nowTimeLabelmm;
@property (nonatomic, strong) UILabel *nowTimeColonLabelB;
@property (nonatomic, strong) UILabel *nowTimeLabelss;

@property (nonatomic, strong) UILabel *differentDayLabel;

// Data

@property (nonatomic, strong) MirrorDataModel *taskModel; //通过taskname在本地db取值
@property (nonatomic, strong) NSDate *nowTime;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, assign) NSTimeInterval timeInterval;


@end

@interface TimeTrackingView ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation TimeTrackingView

- (instancetype)initWithTaskName:(NSString *)taskName
{
    self = [super init];
    if (self) {
        self.taskModel = [MirrorStorage getTaskFromDB:taskName];
        [self p_setupUI];
    }
    return self;
}

- (void)dealloc // 页面被销毁，销毁timer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview // 页面被游离，销毁timer
{
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview && self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)p_setupUI
{
    self.backgroundColor = [UIColor mirrorColorNamed:self.taskModel.color];
    [self addSubview:self.taskNameLabel];
    [self.taskNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.centerY.offset(-180);
        make.width.equalTo(@(kScreenWidth - 2*kPadding));
    }];
    [self addSubview:self.timeIntervalLabel];
    [self.timeIntervalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.centerY.equalTo(self.taskNameLabel.mas_bottom).offset(80);
        make.width.equalTo(@(kScreenWidth - 2*kPadding));
    }];
    
    [self addSubview:self.startTimeLabelHH];
    [self addSubview:self.startTimeColonLabelA];
    [self addSubview:self.startTimeLabelmm];
    [self addSubview:self.startTimeColonLabelB];
    [self addSubview:self.startTimeLabelss];

    [self addSubview:self.dashLabel];

    [self addSubview:self.nowTimeLabelHH];
    [self addSubview:self.nowTimeColonLabelA];
    [self addSubview:self.nowTimeLabelmm];
    [self addSubview:self.nowTimeColonLabelB];
    [self addSubview:self.nowTimeLabelss];
    
    [self.dashLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.centerY.equalTo(self.timeIntervalLabel.mas_bottom).offset(40);
    }];
    
    [self.startTimeLabelss mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.dashLabel.mas_left).offset(-kDashSpacing);
        make.centerY.equalTo(self.dashLabel);
    }];
    [self.startTimeColonLabelB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.startTimeLabelss.mas_left).offset(-kTimeSpacing);
        make.centerY.equalTo(self.startTimeLabelss);
    }];
    [self.startTimeLabelmm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.startTimeColonLabelB.mas_left).offset(-kTimeSpacing);
        make.centerY.equalTo(self.startTimeColonLabelB);
    }];
    [self.startTimeColonLabelA mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.startTimeLabelmm.mas_left).offset(-kTimeSpacing);
        make.centerY.equalTo(self.startTimeLabelmm);
    }];
    [self.startTimeLabelHH mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.startTimeColonLabelA.mas_left).offset(-kTimeSpacing);
        make.centerY.equalTo(self.startTimeColonLabelA);
    }];
    
    [self.nowTimeLabelHH mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.dashLabel.mas_right).offset(kDashSpacing);
        make.centerY.equalTo(self.dashLabel);
    }];
    [self.nowTimeColonLabelA mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nowTimeLabelHH.mas_right).offset(kTimeSpacing);
        make.centerY.equalTo(self.nowTimeLabelHH);
    }];
    [self.nowTimeLabelmm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nowTimeColonLabelA.mas_right).offset(kTimeSpacing);
        make.centerY.equalTo(self.nowTimeColonLabelA);
    }];
    [self.nowTimeColonLabelB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nowTimeLabelmm.mas_right).offset(kTimeSpacing);
        make.centerY.equalTo(self.nowTimeLabelmm);
    }];
    [self.nowTimeLabelss mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nowTimeColonLabelB.mas_right).offset(kTimeSpacing);
        make.centerY.equalTo(self.nowTimeColonLabelB);
    }];
    
    [self addSubview:self.differentDayLabel];
    [self.differentDayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.startTimeLabelss.mas_top);
        make.centerX.equalTo(self.startTimeLabelss.mas_right);
    }];
    self.differentDayLabel.hidden = YES;
    
    // 轻点停止计时
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stopButtonClicked)];
    [self addGestureRecognizer:tapRecognizer];
    
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)1.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
        // 在iOS 10以后系统，苹果针对NSTimer进行了优化，使用Block回调方式，解决了循环引用问题。
        [weakSelf updateLabels];
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

#pragma mark - Actions

- (void)updateLabels
{
    // set up formatters
    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc]init];
    hourFormatter.dateFormat = @"HH";
    NSDateFormatter *minFormatter = [[NSDateFormatter alloc]init];
    minFormatter.dateFormat = @"mm";
    NSDateFormatter *secFormatter = [[NSDateFormatter alloc]init];
    secFormatter.dateFormat = @"ss";
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc]init];
    dayFormatter.dateFormat = @"yyyy-MM-dd";
    
    // udpate start time
    self.startTimeLabelHH.text = [hourFormatter stringFromDate:self.startTime];
    self.startTimeLabelmm.text = [minFormatter stringFromDate:self.startTime];
    self.startTimeLabelss.text = [secFormatter stringFromDate:self.startTime];
    
    // update now time
    self.nowTimeLabelHH.text = [hourFormatter stringFromDate:self.nowTime];
    self.nowTimeLabelmm.text = [minFormatter stringFromDate:self.nowTime];
    self.nowTimeLabelss.text = [secFormatter stringFromDate:self.nowTime];
    
    // update time interval
    self.timeIntervalLabel.text = [[NSDateComponentsFormatter new] stringFromTimeInterval:self.timeInterval];
    
    BOOL printTimeStamp = NO; // 是否打印时间戳（平时不需要打印，出错debug的时候打印一下）
    NSLog(@"%@全屏计时中: %@(now) - %@(start) = %f",[UIColor getEmoji:self.taskModel.color], [MirrorTool timeFromDate:self.nowTime printTimeStamp:printTimeStamp], [MirrorTool timeFromDate:self.startTime printTimeStamp:printTimeStamp], self.timeInterval);
    
    if (round(self.timeInterval) >= kMaxSeconds) { // 超过24小时立即停止计时
        [self.delegate destroyTimeTrackingView];
        [MirrorStorage stopTask:self.taskModel.taskName];
    }
    if (round(self.timeInterval) < 0) { // interval为负数立即停止计时
        [self.delegate destroyTimeTrackingView];
        [MirrorStorage stopTask:self.taskModel.taskName];
        
    }
    if (![[dayFormatter stringFromDate:self.nowTime] isEqualToString:[dayFormatter stringFromDate:self.startTime]]) { // 如果两个时间不在同一天，给startTime一个[日期]的标记
        self.differentDayLabel.hidden = NO;
        self.differentDayLabel.text = [dayFormatter stringFromDate:self.startTime];
    }
}

- (void)stopButtonClicked
{
    [self.delegate destroyTimeTrackingView];
    [MirrorStorage stopTask:self.taskModel.taskName];
}

#pragma mark - Data

- (NSDate *)nowTime
{
    return [NSDate now]; // 当前时间
}

- (NSDate *)startTime
{
    long startTimestamp = 0;
    NSArray *periods = self.taskModel.periods;
    if (periods.count > 0) {
        NSArray *latestPeriod = periods[0];
        if (latestPeriod.count == 1) { // the latest period is ongoing
            startTimestamp = [latestPeriod[0] longValue];
        }
    }
    //     使用 po round(([NSDate now]timeIntervalSince1970] - (kMaxSeconds-20))) 的结果替换下面的startTimestamp可以在20秒内看到超时自动保存的效果
    NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:startTimestamp];
    return startTime;
}

- (NSTimeInterval)timeInterval
{
    return [self.nowTime timeIntervalSinceDate:self.startTime];
}

#pragma mark - Getters

- (UILabel *)taskNameLabel
{
    if (!_taskNameLabel) {
        _taskNameLabel = [UILabel new];
        _taskNameLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        _taskNameLabel.font = [UIFont fontWithName:kHintFont size:kTaskNameSize];
        _taskNameLabel.text = self.taskModel.taskName;
        _taskNameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _taskNameLabel;
}

- (UILabel *)timeIntervalLabel
{
    if (!_timeIntervalLabel) {
        _timeIntervalLabel = [UILabel new];
        _timeIntervalLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        _timeIntervalLabel.font = [UIFont fontWithName:kHintFont size:kIntervalSize];
        _timeIntervalLabel.text = [MirrorLanguage mirror_stringWithKey:@"go"];
        _timeIntervalLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _timeIntervalLabel;
}

- (UILabel *)startTimeLabelHH
{
    if (!_startTimeLabelHH) {
        _startTimeLabelHH = [UILabel new];
        _startTimeLabelHH.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _startTimeLabelHH.font = [UIFont fontWithName:kHintFont size:kHintSize];
        _startTimeLabelHH.text = @"00";
    }
    return _startTimeLabelHH;
}

- (UILabel *)startTimeColonLabelA
{
    if (!_startTimeColonLabelA) {
        _startTimeColonLabelA = [UILabel new];
        _startTimeColonLabelA.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _startTimeColonLabelA.font = [UIFont fontWithName:kHintFont size:kHintSize];
        _startTimeColonLabelA.text = @":";
    }
    return _startTimeColonLabelA;
}

- (UILabel *)startTimeLabelmm
{
    if (!_startTimeLabelmm) {
        _startTimeLabelmm = [UILabel new];
        _startTimeLabelmm.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _startTimeLabelmm.font = [UIFont fontWithName:kHintFont size:kHintSize];
        _startTimeLabelmm.text = @"00";
    }
    return _startTimeLabelmm;
}

- (UILabel *)startTimeColonLabelB
{
    if (!_startTimeColonLabelB) {
        _startTimeColonLabelB = [UILabel new];
        _startTimeColonLabelB.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _startTimeColonLabelB.font = [UIFont fontWithName:kHintFont size:kHintSize];
        _startTimeColonLabelB.text = @":";
    }
    return _startTimeColonLabelB;
}

- (UILabel *)startTimeLabelss
{
    if (!_startTimeLabelss) {
        _startTimeLabelss = [UILabel new];
        _startTimeLabelss.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _startTimeLabelss.font = [UIFont fontWithName:kHintFont size:kHintSize];
        _startTimeLabelss.text = @"00";
    }
    return _startTimeLabelss;
}

- (UILabel *)dashLabel
{
    if (!_dashLabel) {
        _dashLabel = [UILabel new];
        _dashLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _dashLabel.font = [UIFont fontWithName:kHintFont size:kHintSize];
        _dashLabel.text = @"-";
    }
    return _dashLabel;
}

- (UILabel *)nowTimeLabelHH
{
    if (!_nowTimeLabelHH) {
        _nowTimeLabelHH = [UILabel new];
        _nowTimeLabelHH.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _nowTimeLabelHH.font = [UIFont fontWithName:kHintFont size:kHintSize];
        _nowTimeLabelHH.text = @"00";
    }
    return _nowTimeLabelHH;
}

- (UILabel *)nowTimeColonLabelA
{
    if (!_nowTimeColonLabelA) {
        _nowTimeColonLabelA = [UILabel new];
        _nowTimeColonLabelA.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _nowTimeColonLabelA.font = [UIFont fontWithName:kHintFont size:kHintSize];
        _nowTimeColonLabelA.text = @":";
    }
    return _nowTimeColonLabelA;
}

- (UILabel *)nowTimeLabelmm
{
    if (!_nowTimeLabelmm) {
        _nowTimeLabelmm = [UILabel new];
        _nowTimeLabelmm.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _nowTimeLabelmm.font = [UIFont fontWithName:kHintFont size:kHintSize];
        _nowTimeLabelmm.text = @"00";
    }
    return _nowTimeLabelmm;
}

- (UILabel *)nowTimeColonLabelB
{
    if (!_nowTimeColonLabelB) {
        _nowTimeColonLabelB = [UILabel new];
        _nowTimeColonLabelB.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _nowTimeColonLabelB.font = [UIFont fontWithName:kHintFont size:kHintSize];
        _nowTimeColonLabelB.text = @":";
    }
    return _nowTimeColonLabelB;
}


- (UILabel *)nowTimeLabelss
{
    if (!_nowTimeLabelss) {
        _nowTimeLabelss = [UILabel new];
        _nowTimeLabelss.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _nowTimeLabelss.font = [UIFont fontWithName:kHintFont size:kHintSize];
        _nowTimeLabelss.text = @"00";
    }
    return _nowTimeLabelss;
}

- (UILabel *)differentDayLabel
{
    if (!_differentDayLabel) {
        _differentDayLabel = [UILabel new];
        _differentDayLabel.textColor = [UIColor redColor];
        _differentDayLabel.font = [UIFont fontWithName:kHintFont size:13];
        _differentDayLabel.backgroundColor = [UIColor colorWithRed:255 green:0 blue:0 alpha:0.1];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentJustified;
        style.firstLineHeadIndent = 10.0f;
        style.headIndent = 5;
        style.tailIndent = 5;
        NSDateFormatter *dayFormatter = [[NSDateFormatter alloc]init];
        dayFormatter.dateFormat = @"yyyy-MM-dd";
        NSString *text = [dayFormatter stringFromDate:self.startTime];
        NSAttributedString *attributedStr = [[NSAttributedString alloc]initWithString:text attributes:@{NSParagraphStyleAttributeName:style}];
        _differentDayLabel.attributedText = attributedStr;
        _differentDayLabel.layer.cornerRadius = 4;
        _differentDayLabel.layer.masksToBounds = YES;
    }
    return _differentDayLabel;
}

@end
