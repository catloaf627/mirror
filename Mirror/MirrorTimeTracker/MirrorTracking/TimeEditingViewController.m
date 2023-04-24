//
//  TimeEditingViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/24.
//

#import "TimeEditingViewController.h"
#import <Masonry/Masonry.h>
#import "MirrorStorage.h"
#import "MirrorSettings.h"
#import "MirrorMacro.h"
#import "CellAnimation.h"

@interface TimeEditingViewController () <UIViewControllerTransitioningDelegate>

// UI

@property (nonatomic, strong) UILabel *tasknameLabel;
@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic, strong) UILabel *endLabel;
@property (nonatomic, strong) UIDatePicker *startPicker;
@property (nonatomic, strong) UIDatePicker *endPicker;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UILabel *orLabel;
@property (nonatomic, strong) UIButton *startButton;

// Data
@property (nonatomic, strong) NSString *taskName;

@end

@implementation TimeEditingViewController

- (instancetype)initWithTaskName:(NSString *)taskName
{
    self = [super init];
    if (self) {
        self.taskName = taskName;
        self.tasknameLabel.text = taskName;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self p_setupUI];
}

- (void)p_setupUI
{
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor mirrorColorNamed:[MirrorStorage getTaskFromDB:self.taskName].color];
    [self.view addSubview:self.tasknameLabel];
    [self.tasknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.offset(100);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(kScreenWidth);
    }];
    [self.view addSubview:self.startLabel];
    [self.startLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.top.mas_equalTo(self.tasknameLabel.mas_bottom).offset(20);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo((kScreenWidth - 2*20)/3);
    }];
    [self.view addSubview:self.endLabel];
    [self.endLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.top.mas_equalTo(self.startLabel.mas_bottom).offset(20);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo((kScreenWidth - 2*20)/3);
    }];
    [self.view addSubview:self.startPicker];
    [self.startPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-20);
        make.top.mas_equalTo(self.tasknameLabel.mas_bottom).offset(20);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(2*(kScreenWidth - 2*20)/3);
    }];
    [self.view addSubview:self.endPicker];
    [self.endPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-20);
        make.top.mas_equalTo(self.startPicker.mas_bottom).offset(20);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(2*(kScreenWidth - 2*20)/3);
    }];
    [self.view addSubview:self.saveButton];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.mas_equalTo(self.endPicker.mas_bottom).offset(20);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(2*(kScreenWidth - 2*20)/3);
    }];
    [self.view addSubview:self.orLabel];
    [self.orLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.mas_equalTo(self.saveButton.mas_bottom).offset(20);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(2*(kScreenWidth - 2*20)/3);
    }];
    [self.view addSubview:self.startButton];
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.mas_equalTo(self.orLabel.mas_bottom).offset(20);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(2*(kScreenWidth - 2*20)/3);
    }];
    // 动画
    UIPanGestureRecognizer *panRecognizer = [UIPanGestureRecognizer new];
    [panRecognizer addTarget:self action:@selector(panGestureRecognizerAction:)];
    [self.view addGestureRecognizer:panRecognizer];
    
    self.transitioningDelegate = self;
}
    
#pragma mark - Actions
    
- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)pan
{
    // pan手势在元素上，返回
    CGPoint touchPoint = [pan locationInView:self.view];
    for (UIView *subview in self.view.subviews) {
        if (CGRectContainsPoint(subview.frame, touchPoint)) {
            return;
        }
    }
    [self dismiss];
}
    
- (void)dismiss
{
    for (UIView *subview in self.view.subviews) {
        subview.hidden = YES;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Getters

- (UILabel *)tasknameLabel
{
    if (!_tasknameLabel) {
        _tasknameLabel = [UILabel new];
        _tasknameLabel.textAlignment = NSTextAlignmentCenter;
        _tasknameLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        _tasknameLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:20];
    }
    return _tasknameLabel;
}

- (UILabel *)startLabel
{
    if (!_startLabel) {
        _startLabel = [UILabel new];
        _startLabel.text = @"Starts at";
        _startLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        _startLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:17];
    }
    return _startLabel;
}

- (UILabel *)endLabel
{
    if (!_endLabel) {
        _endLabel = [UILabel new];
        _endLabel.text = @"Ends at";
        _endLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        _endLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:17];
    }
    return _endLabel;
}

- (UIDatePicker *)startPicker
{
    if (!_startPicker) {
        _startPicker = [UIDatePicker new];
        _startPicker.datePickerMode = UIDatePickerModeDateAndTime;
        _startPicker.timeZone = [NSTimeZone systemTimeZone];
        _startPicker.preferredDatePickerStyle = UIDatePickerStyleCompact;
        _startPicker.overrideUserInterfaceStyle = [MirrorSettings appliedDarkMode] ? UIUserInterfaceStyleDark:UIUserInterfaceStyleLight;
        _startPicker.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_startPicker addTarget:self action:@selector(changeStartTime) forControlEvents:UIControlEventEditingDidEnd];
    }
    return _startPicker;
}

- (UIDatePicker *)endPicker
{
    if (!_endPicker) {
        _endPicker = [UIDatePicker new];
        _endPicker.datePickerMode = UIDatePickerModeDateAndTime;
        _endPicker.timeZone = [NSTimeZone systemTimeZone];
        _endPicker.preferredDatePickerStyle = UIDatePickerStyleCompact;
        _endPicker.overrideUserInterfaceStyle = [MirrorSettings appliedDarkMode] ? UIUserInterfaceStyleDark:UIUserInterfaceStyleLight;
        _endPicker.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_endPicker addTarget:self action:@selector(changeEndTime) forControlEvents:UIControlEventEditingDidEnd];
    }
    return _endPicker;
}

- (UIButton *)saveButton
{
    if (!_saveButton) {
        _saveButton = [UIButton new];
        [_saveButton setTitle:@"Save record" forState:UIControlStateNormal];
        [_saveButton setTitleColor:[UIColor mirrorColorNamed:MirrorColorTypeText] forState:UIControlStateNormal];
        _saveButton.titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:20];
        _saveButton.layer.borderColor = [UIColor mirrorColorNamed:MirrorColorTypeText].CGColor;
        _saveButton.layer.borderWidth = 1;
        _saveButton.layer.cornerRadius = 12;
    }
    return _saveButton;
}

- (UILabel *)orLabel
{
    if (!_orLabel) {
        _orLabel = [UILabel new];
        _orLabel.text = @"OR";
        _orLabel.textAlignment = NSTextAlignmentCenter;
        _orLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        _orLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:20];
    }
    return _orLabel;
}


- (UIButton *)startButton
{
    if (!_startButton) {
        _startButton = [UIButton new];
        [_startButton setTitle:@"Starts now" forState:UIControlStateNormal];
        _startButton.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_startButton setTitleColor:[UIColor mirrorColorNamed:MirrorColorTypeBackground] forState:UIControlStateNormal];
        _startButton.titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:20];
        _startButton.layer.borderColor = [UIColor mirrorColorNamed:MirrorColorTypeText].CGColor;
        _startButton.layer.borderWidth = 1;
        _startButton.layer.cornerRadius = 12;
    }
    return _startButton;
}
    
#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    CellAnimation *animation = [CellAnimation new];
    animation.isPresent = NO;
    animation.cellFrame = self.cellFrame;
    return animation;
}


#pragma mark - Privates

//- (NSDate *)startMaxDate
//{
//    MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
//    long maxTime = 0;
//    // 对于一个开始时间来说，它最小不能小于上一个task的结束时间（如果有上一个task的话），最大不能大于自己的结束时间
//    maxTime = [task.periods[self.periodIndex][1] longValue] - kMinSeconds; // 至多比自己的结束时间小一分钟
//    return [NSDate dateWithTimeIntervalSince1970:maxTime];
//}
//
//- (NSDate *)endMaxDate
//{
//    MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
//    long maxTime = 0;
//    // 对于一个结束时间来说，它最小不能小于自己的开始时间，最大不能大于下一个task的开始时间（如果有下一个task的话）
//    if (self.periodIndex-1 >= 0) { // 如果有下一个task的话
//        NSArray *latterPeriod = task.periods[self.periodIndex-1];
//        maxTime = [latterPeriod[0] longValue]; // 至多也要等于下一个task的开始时间
//    } else {
//        maxTime = LONG_MAX;
//    }
//    return [NSDate dateWithTimeIntervalSince1970:maxTime];
//}
//
//
//- (NSDate *)startMinDate
//{
//    MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
//    long minTime = 0;
//    // 对于一个开始时间来说，它最小不能小于上一个task的结束时间（如果有上一个task的话），最大不能大于自己的结束时间
//    if (self.periodIndex+1 < task.periods.count) { //如果有上一个task的话
//        NSArray *formerPeriod = task.periods[self.periodIndex+1];
//        minTime = [formerPeriod[1] longValue]; // 至少等于前一个task的结束时间
//    } else {
//        minTime = 0;
//    }
//
//    return [NSDate dateWithTimeIntervalSince1970:minTime];
//}
//
//- (NSDate *)endMinDate
//{
//    MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
//    long minTime = 0;
//    // 对于一个结束时间来说，它最小不能小于自己的开始时间，最大不能大于下一个task的开始时间（如果有下一个task的话）
//    minTime = [task.periods[self.periodIndex][0] longValue] + kMinSeconds;// 至少比开始的时间多一分钟
//    return [NSDate dateWithTimeIntervalSince1970:minTime];
//}



@end
