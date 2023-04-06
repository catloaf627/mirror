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

static CGFloat const kPadding = 20;

static CGFloat const kTaskNameSize = 35;
static CGFloat const kIntervalSize = 70;
static CGFloat const kHintSize = 25;

static NSString *const kHintFont = @"TrebuchetMS-Italic";
static CGFloat const kTimeSpacing = 5;
static CGFloat const kDashSpacing = 10;

@interface TimeTrackingView ()

@property (nonatomic, strong) MirrorDataModel *taskModel;

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

@property (nonatomic, strong) UILabel *yesterdayLabel;

@end

@implementation TimeTrackingView

- (instancetype)initWithTask:(MirrorDataModel *)taskModel
{
    self = [super init];
    if (self) {
        self.taskModel = taskModel;
        self.backgroundColor = [UIColor mirrorColorNamed:taskModel.color];
        [self p_setupUI];
    }
    return self;
}

- (void)p_setupUI
{
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
    
    [self addSubview:self.yesterdayLabel];
    [self.yesterdayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.startTimeLabelss.mas_top);
        make.centerX.equalTo(self.startTimeLabelss.mas_right);
    }];
    self.yesterdayLabel.hidden = YES;
    
    // 轻点停止计时
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stopButtonClicked)];
    [self addGestureRecognizer:tapRecognizer];
    
    // 每秒实时更新展示时间
    [self updateLabels];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
    
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
    NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:1666561000]; //gizmo
    self.startTimeLabelHH.text = [hourFormatter stringFromDate:startTime];
    self.startTimeLabelmm.text = [minFormatter stringFromDate:startTime];
    self.startTimeLabelss.text = [secFormatter stringFromDate:startTime];
    
    // update now time
    NSDate *nowTime = [NSDate date]; // 当前时间
    self.nowTimeLabelHH.text = [hourFormatter stringFromDate:nowTime];
    self.nowTimeLabelmm.text = [minFormatter stringFromDate:nowTime];
    self.nowTimeLabelss.text = [secFormatter stringFromDate:nowTime];
    
    // update time interval
    NSTimeInterval timeInterval = [nowTime timeIntervalSinceDate:startTime];
    self.timeIntervalLabel.text = [[NSDateComponentsFormatter new] stringFromTimeInterval:timeInterval];
//    if (timeInterval >= 86400 || timeInterval < 0) { // 超过一天或者interval为负数立即停止计时
//        [self.delegate closeTimeTrackingView];
//    }
    if (![[dayFormatter stringFromDate:nowTime] isEqualToString:[dayFormatter stringFromDate:startTime]]) { // 如果两个时间不在同一天（跨越了0点），给startTime一个[昨天]的标记
        self.yesterdayLabel.hidden = NO;
    }
    
//    NSLog(@"当前时间 %d", (int)[NSDate date].timeIntervalSince1970);
}

- (void)stopButtonClicked
{
    [self.delegate closeTimeTrackingViewWithTask:self.taskModel];
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
        _timeIntervalLabel.text = @"00:00:00";
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

- (UILabel *)yesterdayLabel
{
    if (!_yesterdayLabel) {
        _yesterdayLabel = [UILabel new];
        _yesterdayLabel.textColor = [UIColor redColor];
        _yesterdayLabel.font = [UIFont fontWithName:kHintFont size:13];
        _yesterdayLabel.backgroundColor = [UIColor colorWithRed:255 green:0 blue:0 alpha:0.1];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentJustified;
        style.firstLineHeadIndent = 10.0f;
        style.headIndent = 5;
        style.tailIndent = 5;
        NSAttributedString *attributedStr = [[NSAttributedString alloc]initWithString:[MirrorLanguage mirror_stringWithKey:@"yesterday"] attributes:@{NSParagraphStyleAttributeName:style}];
        _yesterdayLabel.attributedText = attributedStr;
        _yesterdayLabel.layer.cornerRadius = 4;
        _yesterdayLabel.layer.masksToBounds = YES;
    }
    return _yesterdayLabel;
}

@end
