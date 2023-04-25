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
#import "MirrorLanguage.h"
#import "MirrorTimeText.h"

@interface TimeEditingViewController () <UIViewControllerTransitioningDelegate>

// UI
@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) UILabel *tasknameLabel;
@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic, strong) UILabel *endLabel;
@property (nonatomic, strong) UIDatePicker *startPicker;
@property (nonatomic, strong) UIDatePicker *endPicker;
@property (nonatomic, strong) UILabel *totalLabel;
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
    [self.view addSubview:self.totalLabel];
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset((kScreenWidth - 160 - 80 - 20)/2);
        make.top.mas_equalTo(self.endPicker.mas_bottom).offset(20);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(160);
    }];
    [self.view addSubview:self.saveButton];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-(kScreenWidth - 160 - 80 - 20)/2);
        make.top.mas_equalTo(self.endPicker.mas_bottom).offset(20);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(80);
    }];
    [self.view addSubview:self.orLabel];
    [self.orLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.mas_equalTo(self.saveButton.mas_bottom).offset(20);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(3*(kScreenWidth - 2*20)/4);
    }];
    [self.view addSubview:self.startButton];
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.mas_equalTo(self.orLabel.mas_bottom).offset(20);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(3*(kScreenWidth - 2*20)/4);
    }];
    
    [self.view addSubview:self.dismissButton];
    [self.dismissButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-20);
        make.bottom.mas_equalTo(self.tasknameLabel.mas_top);
        make.width.height.mas_equalTo(40);
    }];
    
    // 直接返回的手势
    UIPanGestureRecognizer *panRecognizer = [UIPanGestureRecognizer new];
    [panRecognizer addTarget:self action:@selector(panGestureRecognizerAction:)];
    [self.view addGestureRecognizer:panRecognizer];
    UITapGestureRecognizer *tapRecognizer = [UITapGestureRecognizer new];
    [tapRecognizer addTarget:self action:@selector(tapGestureRecognizerAction:)];
    [self.view addGestureRecognizer:tapRecognizer];
    
    // 动画
    self.transitioningDelegate = self;
    
    // Picker
    [self updatePickerRange];
}

- (void)updatePickerRange
{
    [self roundPickerDate];
    self.startPicker.maximumDate = self.endPicker.date;
    self.startPicker.minimumDate = [NSDate dateWithTimeIntervalSince1970:[self formmerPeriodEndTime]];
    self.endPicker.minimumDate = self.startPicker.date;
    long start = [self.startPicker.date timeIntervalSince1970];
    long end = [self.endPicker.date timeIntervalSince1970];
    self.totalLabel.text = [[MirrorLanguage mirror_stringWithKey:@"lasted"] stringByAppendingString:[MirrorTimeText XdXhXmXsShortWithstart:start end:end]];
}
    
#pragma mark - Actions
    
- (void)changeStartTime
{
    [self updatePickerRange]; // 只更新另一个picker的range，不保存数据
}

- (void)changeEndTime
{
    [self updatePickerRange]; // 只更新另一个picker的range，不保存数据
}

- (void)startCounting
{
    [MirrorStorage startTask:self.taskName at:[NSDate now] periodIndex:0];
    [self dismissViewControllerAnimated:NO completion:nil]; // present time tracking vc，此时 time editing vc的退场不需要动画
}

- (void)saveRecord
{
    [MirrorStorage startTask:self.taskName at:self.startPicker.date periodIndex:0];
    [MirrorStorage stopTask:self.taskName at:self.endPicker.date periodIndex:0];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)pan // 摸到 startbutton 下方 20pt，dismiss
{
    CGPoint touchPoint = [pan locationInView:self.view];
    if (touchPoint.y > self.startButton.frame.origin.y + self.startButton.frame.size.height + 20) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)tapGestureRecognizerAction:(UITapGestureRecognizer *)tap // 摸到 startbutton 下方 20pt，dismiss
{
    CGPoint touchPoint = [tap locationInView:self.view];
    if (touchPoint.y > self.startButton.frame.origin.y + self.startButton.frame.size.height + 20) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getters
    
- (UIButton *)dismissButton
{
    if (!_dismissButton) {
        _dismissButton = [UIButton new];
        UIImage *iconImage = [[UIImage systemImageNamed:@"xmark"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_dismissButton setImage:[iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _dismissButton.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissButton;
}

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
        _startLabel.textAlignment = NSTextAlignmentCenter;
        _startLabel.text = [MirrorLanguage mirror_stringWithKey:@"starts_at"];
        _startLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _startLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:17];
    }
    return _startLabel;
}

- (UILabel *)endLabel
{
    if (!_endLabel) {
        _endLabel = [UILabel new];
        _endLabel.textAlignment = NSTextAlignmentCenter;
        _endLabel.text = [MirrorLanguage mirror_stringWithKey:@"ends_at"];
        _endLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _endLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:17];
    }
    return _endLabel;
}

- (UIDatePicker *)startPicker
{
    if (!_startPicker) {
        _startPicker = [UIDatePicker new];
        _startPicker.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _startPicker.datePickerMode = UIDatePickerModeDateAndTime;
        _startPicker.timeZone = [NSTimeZone systemTimeZone];
        _startPicker.preferredDatePickerStyle = UIDatePickerStyleCompact;
        _startPicker.overrideUserInterfaceStyle = [MirrorSettings appliedDarkMode] ? UIUserInterfaceStyleDark:UIUserInterfaceStyleLight;
        _startPicker.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        // 如果上一个任务的结束时间在未来，设置start picker和未来那个数字对齐，否则，使用现在的时间
        _startPicker.date = [self formmerPeriodEndTime] > [[NSDate now] timeIntervalSince1970]  ? [NSDate dateWithTimeIntervalSince1970:[self formmerPeriodEndTime]] : [NSDate now];
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
        // end picker初始值为start picker + 1hour
        _endPicker.date = [NSDate dateWithTimeIntervalSince1970:([self.startPicker.date timeIntervalSince1970] + 3600)];
        [_endPicker addTarget:self action:@selector(changeEndTime) forControlEvents:UIControlEventEditingDidEnd];
    }
    return _endPicker;
}

- (UILabel *)totalLabel
{
    if (!_totalLabel) {
        _totalLabel = [UILabel new];
        _totalLabel.adjustsFontSizeToFitWidth = YES;
        _totalLabel.textAlignment = NSTextAlignmentCenter;
        _totalLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        _totalLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:20];
    }
    return _totalLabel;
}

- (UIButton *)saveButton
{
    if (!_saveButton) {
        _saveButton = [UIButton new];
        [_saveButton setTitle:[MirrorLanguage mirror_stringWithKey:@"save"] forState:UIControlStateNormal];
        [_saveButton setTitleColor:[UIColor mirrorColorNamed:MirrorColorTypeText] forState:UIControlStateNormal];
        _saveButton.titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:20];
        _saveButton.layer.borderColor = [UIColor mirrorColorNamed:MirrorColorTypeText].CGColor;
        _saveButton.layer.borderWidth = 1;
        _saveButton.layer.cornerRadius = 12;
        [_saveButton addTarget:self action:@selector(saveRecord) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

- (UILabel *)orLabel
{
    if (!_orLabel) {
        _orLabel = [UILabel new];
        _orLabel.text = [MirrorLanguage mirror_stringWithKey:@"or"];
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
        [_startButton setTitle:[MirrorLanguage mirror_stringWithKey:@"start_now"] forState:UIControlStateNormal];
        _startButton.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_startButton setTitleColor:[UIColor mirrorColorNamed:MirrorColorTypeBackground] forState:UIControlStateNormal];
        _startButton.titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:20];
        _startButton.layer.borderColor = [UIColor mirrorColorNamed:MirrorColorTypeText].CGColor;
        _startButton.layer.borderWidth = 1;
        _startButton.layer.cornerRadius = 12;
        [_startButton addTarget:self action:@selector(startCounting) forControlEvents:UIControlEventTouchUpInside];
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

- (long)formmerPeriodEndTime
{
    MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
    NSInteger periodsCnt = task.periods.count;
    if  (periodsCnt > 0) {
        NSArray *formerPeriod = task.periods[0];
        return [formerPeriod[1] longValue];
    } else {
        return LONG_MIN;
    }
}

- (void)roundPickerDate
{
    // 先改endpicker，因为删掉second相当于往小减，如果先改了startpicker，endpicker可能会变
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *ends = [gregorian components:NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond fromDate:self.endPicker.date];
    ends.timeZone = [NSTimeZone systemTimeZone];
    ends.second = 0;
    self.endPicker.date = [gregorian dateFromComponents:ends];
    
    NSDateComponents *starts = [gregorian components:NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond fromDate:self.startPicker.date];
    starts.timeZone = [NSTimeZone systemTimeZone];
    starts.second = 0;
    self.startPicker.date = [gregorian dateFromComponents:starts];
}

@end
