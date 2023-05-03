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

@interface TimeEditingViewController () <UIViewControllerTransitioningDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

// UI
@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) UILabel *tasknameLabel;
@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic, strong) UIDatePicker *startPicker;
@property (nonatomic, strong) UIPickerView *lastedPicker;
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
    [self.view addSubview:self.startPicker];
    [self.startPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-20);
        make.top.mas_equalTo(self.tasknameLabel.mas_bottom).offset(20);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(2*(kScreenWidth - 2*20)/3);
    }];
    [self.view addSubview:self.lastedPicker];
    [self.lastedPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.top.mas_equalTo(self.startPicker.mas_bottom).offset(20);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo((kScreenWidth - 3*20)/2);
    }];
    [self.view addSubview:self.saveButton];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.lastedPicker.mas_right).offset(20);
        make.centerY.mas_equalTo(self.lastedPicker);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo((kScreenWidth - 3*20)/2);
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
    
    // 默认一小时
    [self.lastedPicker selectRow:1 inComponent:0 animated:NO];
}

#pragma mark - Actions
    

- (void)startCounting
{
    [MirrorStorage startTask:self.taskName at:[NSDate now] periodIndex:0];
    [self dismissViewControllerAnimated:NO completion:nil]; // present time tracking vc，此时 time editing vc的退场不需要动画
}

- (void)saveRecord
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *starts = [gregorian components:NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond fromDate:self.startPicker.date];
    starts.timeZone = [NSTimeZone systemTimeZone];
    starts.second = 0;
    NSDate *startDate = [gregorian dateFromComponents:starts]; // 去掉秒数
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:([startDate timeIntervalSince1970] + [self.lastedPicker selectedRowInComponent:0] * 3600 + [self.lastedPicker selectedRowInComponent:1] * 60)];
    [MirrorStorage savePeriodWithTaskname:self.taskName startAt:startDate endAt:endDate];
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

#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return 24;
    } else {
        return 60;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return (kScreenWidth - 3*20)/4;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [UILabel new];
    label.textAlignment = component == 0 ? NSTextAlignmentRight : NSTextAlignmentLeft;
    label.adjustsFontSizeToFitWidth = YES;
    label.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
    label.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:17];
    label.text = component == 0 ? [[@(row)stringValue] stringByAppendingString:row==1 ? [MirrorLanguage mirror_stringWithKey:@"picker_hour"] :[MirrorLanguage mirror_stringWithKey:@"picker_hours"]] : [[@(row)stringValue] stringByAppendingString:row==1 ? [MirrorLanguage mirror_stringWithKey:@"picker_min"] :[MirrorLanguage mirror_stringWithKey:@"picker_mins"]];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerView selectedRowInComponent:1] == 0 && component == 0 && row == 0) { //在分钟为0的情况下选择了0小时
        [pickerView selectRow:1 inComponent:1 animated:YES]; // 把分钟设置为1
    }
    if ([pickerView selectedRowInComponent:0] == 0 && component == 1 && row == 0) { //在小时为0的情况下选择了0分钟
        [pickerView selectRow:1 inComponent:0 animated:YES]; // 把小时设置为1
    }
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

- (UIDatePicker *)startPicker
{
    if (!_startPicker) {
        _startPicker = [UIDatePicker new];
        _startPicker.datePickerMode = UIDatePickerModeDateAndTime;
        _startPicker.timeZone = [NSTimeZone systemTimeZone];
        _startPicker.preferredDatePickerStyle = UIDatePickerStyleCompact;
        _startPicker.overrideUserInterfaceStyle = [MirrorSettings appliedDarkMode] ? UIUserInterfaceStyleDark:UIUserInterfaceStyleLight;
        _startPicker.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        // 如果上一个任务的结束时间在未来，设置start picker和未来那个数字对齐，否则，使用现在的时间
        _startPicker.date = [self formmerPeriodEndTime] > [[NSDate now] timeIntervalSince1970]  ? [NSDate dateWithTimeIntervalSince1970:[self formmerPeriodEndTime]] : [NSDate now];
    }
    return _startPicker;
}

- (UIPickerView *)lastedPicker
{
    if (!_lastedPicker) {
        _lastedPicker = [UIPickerView new];
        _lastedPicker.delegate = self;
    }
    return _lastedPicker;
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

@end
