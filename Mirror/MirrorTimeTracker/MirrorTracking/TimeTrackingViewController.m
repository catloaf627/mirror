//
//  TimeTrackingViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/24.
//

#import "TimeTrackingViewController.h"
#import "MirrorDataModel.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "MirrorMacro.h"
#import "MirrorLanguage.h"
#import "MirrorStorage.h"
#import "MirrorTool.h"
#import "CellAnimation.h"
#import "MirrorTimeText.h"

static CGFloat const kPadding = 20;

static CGFloat const kTaskNameSize = 35;
static CGFloat const kIntervalSize = 70;
static CGFloat const kHintSize = 25;

static NSString *const kHintFont = @"TrebuchetMS-Italic";
static CGFloat const kTimeSpacing = 5;
static CGFloat const kDashSpacing = 10;


@interface TimeTrackingViewController () <UIViewControllerTransitioningDelegate>

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

@property (nonatomic, strong) UIButton *stopButton;

// Data

@property (nonatomic, strong) NSString *taskName;
@property (nonatomic, strong) NSDate *nowTime;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, assign) NSTimeInterval timeInterval;


// Timer
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation TimeTrackingViewController

- (instancetype)initWithTaskName:(NSString *)taskName
{
    self = [super init];
    if (self) {
        self.taskName = taskName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_setupUI];
}

- (void)dealloc // 页面被销毁，销毁timer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    for (UIView *subview in self.view.subviews) {
        subview.alpha = 0; // 为了避免退场动画出现时subview的布局出现问题。
    }
}

- (void)p_setupUI
{
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor mirrorColorNamed:[MirrorStorage getTaskFromDB:self.taskName].color];
    [self.view addSubview:self.taskNameLabel];
    [self.taskNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.centerY.offset(-180);
        make.width.equalTo(@(kScreenWidth - 2*kPadding));
    }];
    [self.view addSubview:self.timeIntervalLabel];
    [self.timeIntervalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.centerY.equalTo(self.taskNameLabel.mas_bottom).offset(80);
        make.width.equalTo(@(kScreenWidth - 2*kPadding));
    }];
    
    [self.view addSubview:self.startTimeLabelHH];
    [self.view addSubview:self.startTimeColonLabelA];
    [self.view addSubview:self.startTimeLabelmm];
    [self.view addSubview:self.startTimeColonLabelB];
    [self.view addSubview:self.startTimeLabelss];

    [self.view addSubview:self.dashLabel];

    [self.view addSubview:self.nowTimeLabelHH];
    [self.view addSubview:self.nowTimeColonLabelA];
    [self.view addSubview:self.nowTimeLabelmm];
    [self.view addSubview:self.nowTimeColonLabelB];
    [self.view addSubview:self.nowTimeLabelss];
    
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
    
    [self.view addSubview:self.differentDayLabel];
    [self.differentDayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.startTimeLabelss.mas_top);
        make.centerX.equalTo(self.startTimeLabelss.mas_right);
    }];
    self.differentDayLabel.hidden = YES;
    
    [self.view addSubview:self.stopButton];
    [self.stopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.mas_equalTo(self.nowTimeLabelss.mas_bottom).offset(50);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(3*(kScreenWidth - 2*20)/4); // 和TimeEditingVC 的startbutton保持一个size
    }];
    
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)1.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
        // 在iOS 10以后系统，苹果针对NSTimer进行了优化，使用Block回调方式，解决了循环引用问题。
        [weakSelf updateLabels];
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    // 动画
    self.transitioningDelegate = self;
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
    
    // udpate stop button text
    if (round(self.timeInterval) >= kMinSeconds) {
        [self.stopButton setTitle:[MirrorLanguage mirror_stringWithKey:@"stop"] forState:UIControlStateNormal];
    } else {
        [self.stopButton setTitle:[MirrorLanguage mirror_stringWithKey:@"give_up"] forState:UIControlStateNormal];
    }
    
    
    BOOL printTimeStamp = NO; // 是否打印时间戳（平时不需要打印，出错debug的时候打印一下）
    NSLog(@"%@全屏计时中: %@(now) - %@(start) = %f",[UIColor getEmoji:[MirrorStorage getTaskFromDB:self.taskName].color], [MirrorTool timeFromDate:self.nowTime printTimeStamp:printTimeStamp], [MirrorTool timeFromDate:self.startTime printTimeStamp:printTimeStamp], self.timeInterval);
    
    if (round(self.timeInterval) < 0) { // interval为负数立即停止计时
        [self dismissViewControllerAnimated:YES completion:nil];
        [MirrorStorage stopTask:self.taskName at:[NSDate now] periodIndex:0];
        
    }
    if (![[MirrorTimeText YYYYmmdd:self.nowTime] isEqualToString:[MirrorTimeText YYYYmmdd:self.startTime]]) { // 如果两个时间不在同一天，给startTime一个[日期]的标记
        self.differentDayLabel.hidden = NO;
        self.differentDayLabel.text = [MirrorTimeText YYYYmmdd:self.startTime];
    }
}

- (void)stopButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (round(self.timeInterval) >= kMinSeconds) {
        [MirrorStorage stopTask:self.taskName at:[NSDate now] periodIndex:0];
    } else {
        [MirrorStorage deletePeriodWithTaskname:self.taskName periodIndex:0];
    }
}

#pragma mark - Data

- (NSDate *)nowTime
{
    return [NSDate now]; // 当前时间
}

- (NSDate *)startTime
{
    long startTimestamp = 0;
    NSArray *periods = [MirrorStorage getTaskFromDB:self.taskName].periods;
    if (periods.count > 0) {
        NSArray *latestPeriod = periods[0];
        if (latestPeriod.count == 1) { // the latest period is ongoing
            startTimestamp = [latestPeriod[0] longValue];
        }
    }
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
        _taskNameLabel.text = self.taskName;
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
        _differentDayLabel.layer.cornerRadius = 4;
        _differentDayLabel.layer.masksToBounds = YES;
    }
    return _differentDayLabel;
}

- (UIButton *)stopButton
{
    if (!_stopButton) {
        _stopButton = [UIButton new];
        [_stopButton setTitle:[MirrorLanguage mirror_stringWithKey:@"give_up"] forState:UIControlStateNormal];
        _stopButton.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_stopButton setTitleColor:[UIColor mirrorColorNamed:MirrorColorTypeBackground] forState:UIControlStateNormal];
        _stopButton.titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:20];
        _stopButton.layer.borderColor = [UIColor mirrorColorNamed:MirrorColorTypeText].CGColor;
        _stopButton.layer.borderWidth = 1;
        _stopButton.layer.cornerRadius = 12;
        [_stopButton addTarget:self action:@selector(stopButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopButton;
}


#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    CellAnimation *animation = [CellAnimation new];
    animation.isPresent = NO;
    animation.cellFrame = self.cellFrame;
    return animation;
}


@end
