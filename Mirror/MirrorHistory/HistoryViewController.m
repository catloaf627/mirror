//
//  HistoryViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/19.
//

#import "HistoryViewController.h"
#import "MirrorMacro.h"
#import "MirrorSettings.h"
#import "MirrorTabsManager.h"
#import "MirrorNaviManager.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "LeftAnimation.h"
#import "SettingsViewController.h"
#import "SpanHistogram.h"
#import "SpanLegend.h"
#import "MirrorLanguage.h"
#import "MirrorSettings.h"
#import "MirrorPiechart.h"
#import "MirrorTaskModel.h"
#import "MirrorTool.h"
#import "MirrorStorage.h"
#import "MirrorTimeText.h"
#import "HiddenViewController.h"
#import "HiddenAnimation.h"

static CGFloat const kLeftRightSpacing = 20;

@interface HistoryViewController () <UIViewControllerTransitioningDelegate>

// Navibar
@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;
@property (nonatomic, strong) UIButton *typeButton;
// Data source
@property (nonatomic, strong) NSMutableArray<MirrorDataModel *>  *data;
@property (nonatomic, assign) NSInteger offset;
// UI
@property (nonatomic, strong) UISegmentedControl *typeSwitch;
@property (nonatomic, strong) UIView *interactionView; //在这个view的范围内，点左侧offset-1,点右侧offset+1
@property (nonatomic, strong) UIImageView *leftArrow;
@property (nonatomic, strong) UIImageView *rightArrow;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) SpanLegend *legendView;
@property (nonatomic, strong) SpanHistogram *histogramView;
@property (nonatomic, strong) MirrorPiechart *piechartView;
@property (nonatomic, strong) UILabel *emptyHintLabel;

@end

@implementation HistoryViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 系统通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorSignificantTimeChangeNotification object:nil];
        // 设置通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchThemeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchLanguageNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorSwitchShowIndexNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorSwitchWeekStartsOnNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorSwitchChartTypeDataNotification object:nil];
        // 数据通知 (直接数据驱动UI，本地数据变动必然导致这里的UI变动)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorImportDataNotificaiton object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskHiddenNotification object:nil];// 比其他vc多监听一个hidden通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskStopNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskEditNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskDeleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskCreateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskChangeOrderNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorPeriodDeleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorPeriodEditNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_setupUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[MirrorNaviManager sharedInstance] updateNaviItemWithNaviController:self.navigationController title:@"" leftButton:self.settingsButton rightButton:self.typeButton];
}

- (void)restartVC
{
    // 将vc.view里的所有subviews全部置为nil
    self.typeSwitch = nil;
    self.interactionView = nil;
    self.leftArrow = nil;
    self.rightArrow = nil;
    self.dateLabel = nil;
    self.legendView = nil;
    self.histogramView = nil;
    self.piechartView = nil;
    // 将vc.view里的所有subviews从父view上移除
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 更新tabbar 和 navibar
    [[MirrorTabsManager sharedInstance] updateHistoryTabItemWithTabController:self.tabBarController];
    if (self.tabBarController.selectedIndex == 2) {
        [[MirrorNaviManager sharedInstance] updateNaviItemWithNaviController:self.navigationController title:@"" leftButton:self.settingsButton rightButton:self.typeButton];
    }
    [self p_setupUI];
}

- (void)reloadData
{
    // data source
    [self updateData];
    
    // empty hint
    [self updateHint]; // reloaddata要顺便reload一下emptyhint的状态
    
    // legend
    [self.legendView updateWithData:self.data];
    [self.legendView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([self.legendView legendViewHeight]);
    }];
    
    // histogram
    [self.histogramView updateWithData:self.data];
    self.histogramView.hidden = [MirrorSettings appliedPieChartData];
    
    // piechart
    CGFloat width = MIN([[self leftWidthLeftHeight][0] floatValue], [[self leftWidthLeftHeight][1] floatValue]);
    [self.piechartView updateWithData:self.data width:width enableInteractive:YES];
    if (self.piechartView.superview) { //security
        [self.piechartView mas_updateConstraints:^(MASConstraintMaker *make) {
            if (width == [[self leftWidthLeftHeight][0] floatValue]) { // 宽度小于高度
                make.top.mas_equalTo(self.legendView.mas_bottom).offset(10 + ([[self leftWidthLeftHeight][1] floatValue]-[[self leftWidthLeftHeight][0] floatValue])/2);
                make.width.height.mas_equalTo(width);
            } else {
                make.top.mas_equalTo(self.legendView.mas_bottom).offset(10);
                make.width.height.mas_equalTo(width);
            }
        }];
    }
    self.piechartView.hidden = ![MirrorSettings appliedPieChartData];

}

- (void)p_setupUI
{
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    [self updateData];
    
    [self.view addSubview:self.typeSwitch];
    [self.typeSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kLeftRightSpacing);
        make.right.mas_equalTo(self.view).offset(-kLeftRightSpacing);
        make.top.mas_equalTo(self.view).offset(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
        make.height.mas_equalTo(32);
    }];

    [self.view addSubview:self.interactionView];
    [self.interactionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.typeSwitch.mas_bottom).offset(10);
        make.height.mas_equalTo(60);
    }];
    [self.interactionView addSubview:self.dateLabel];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.offset(0);
        make.width.mas_equalTo(2*self.view.frame.size.width/3);
        make.height.mas_equalTo(40);
    }];
    [self.interactionView addSubview:self.leftArrow];
    [self.leftArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.dateLabel);
        make.right.mas_equalTo(self.dateLabel.mas_left).offset(-10);
    }];
    [self.interactionView addSubview:self.rightArrow];
    [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.dateLabel);
        make.left.mas_equalTo(self.dateLabel.mas_right).offset(10);
    }];
    [self.view addSubview:self.legendView];
    [self.legendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kLeftRightSpacing);
        make.right.mas_equalTo(self.view).offset(-kLeftRightSpacing);
        make.top.mas_equalTo(self.interactionView.mas_bottom).offset(10);
        make.height.mas_equalTo([self.legendView legendViewHeight]);
    }];
    [self.view addSubview:self.histogramView];
    [self.histogramView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kLeftRightSpacing);
        make.right.mas_equalTo(self.view).offset(-kLeftRightSpacing);
        make.top.mas_equalTo(self.legendView.mas_bottom).offset(10);
        make.bottom.mas_equalTo(self.view).offset(-kTabBarHeight - 20);
    }];
    self.histogramView.hidden = [MirrorSettings appliedPieChartData];

    [self.view addSubview:self.piechartView];
    CGFloat width = MIN([[self leftWidthLeftHeight][0] floatValue], [[self leftWidthLeftHeight][1] floatValue]);
    [self.piechartView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (width == [[self leftWidthLeftHeight][0] floatValue]) { // 宽度小于高度
            make.top.mas_equalTo(self.legendView.mas_bottom).offset(10 + ([[self leftWidthLeftHeight][1] floatValue]-[[self leftWidthLeftHeight][0] floatValue])/2);
            make.centerX.offset(0);
            make.width.height.mas_equalTo(width);
        } else {
            make.top.mas_equalTo(self.legendView.mas_bottom).offset(10);
            make.centerX.offset(0);
            make.width.height.mas_equalTo(width);
        }
    }];
    self.piechartView.hidden = ![MirrorSettings appliedPieChartData];
    // empty hint
    [self.view addSubview:self.emptyHintLabel];
    [self.emptyHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.offset(0);
    }];
    UITapGestureRecognizer *tapRecognizer = [UITapGestureRecognizer new];
    [tapRecognizer addTarget:self action:@selector(tapGestureRecognizerAction:)];
    [self.interactionView addGestureRecognizer:tapRecognizer];
    
    UIScreenEdgePanGestureRecognizer *edgeRecognizer = [UIScreenEdgePanGestureRecognizer new];
    edgeRecognizer.edges = UIRectEdgeLeft;
    [edgeRecognizer addTarget:self action:@selector(edgeGestureRecognizerAction:)];
    [self.view addGestureRecognizer:edgeRecognizer];
    
}

#pragma mark - Actions

- (void)goToHiddenVC
{
    [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight] impactOccurred];
    HiddenViewController *hiddenVC = [HiddenViewController new];
    hiddenVC.showShadeButton = NO;
    hiddenVC.transitioningDelegate = self;
    hiddenVC.modalPresentationStyle = UIModalPresentationCustom;
    hiddenVC.buttonFrame = [self.typeButton convertRect:self.typeButton.bounds toView:[[[UIApplication sharedApplication] delegate] window]];
    [self presentViewController:hiddenVC animated:YES completion:nil];
}

- (void)tapGestureRecognizerAction:(UITapGestureRecognizer *)tap // 热区范围为左右1/3
{
    CGPoint touchPoint = [tap locationInView:self.view];
    if (touchPoint.x < self.interactionView.frame.size.width/3) { // 左侧
        self.offset = self.offset - 1;
        [self reloadData];
    } else if (touchPoint.x > 2 * self.interactionView.frame.size.width/3) { // 右侧
        self.offset = self.offset + 1;
        [self reloadData];
    }
    
}

- (void)spanTypeChanged
{
    [MirrorSettings changeSpanType:self.typeSwitch.selectedSegmentIndex];
    self.offset = 0;
    [self reloadData];
}

- (void)goToSettings
{
    [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight] impactOccurred];
    SettingsViewController * settingsVC = [[SettingsViewController alloc] init];
    settingsVC.transitioningDelegate = self;
    settingsVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:settingsVC animated:YES completion:nil];
}

#pragma mark - update data

- (void)updateData
{
    long startTime = 0;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate now]];
    components.timeZone = [NSTimeZone systemTimeZone];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    if (self.typeSwitch.selectedSegmentIndex == SpanTypeDay) {
        startTime = [[gregorian dateFromComponents:components] timeIntervalSince1970];
        if (self.offset != 0) {
            startTime = startTime + 86400*self.offset;
        }
    } else if (self.typeSwitch.selectedSegmentIndex == SpanTypeWeek) {
        long todayZero = [[gregorian dateFromComponents:components] timeIntervalSince1970];
        startTime = todayZero - [MirrorTool getDayGapFromTheFirstDayThisWeek] * 86400;
        if (self.offset != 0) {
            startTime = startTime + 7*86400*self.offset;
        }
    } else if (self.typeSwitch.selectedSegmentIndex == SpanTypeMonth) {
        components.day = 1;
        if (self.offset > 0) {
            for (int i=0;i<self.offset;i++) {
                if (components.month + 1 <= 12) {
                    components.month = components.month + 1;
                } else {
                    components.year = components.year + 1;
                    components.month = 1;
                }
            }
        }
        if (self.offset < 0) {
            for (int i=0;i<-self.offset;i++) {
                if (components.month - 1 >= 1) {
                    components.month = components.month - 1;
                } else {
                    components.year = components.year - 1;
                    components.month = 12;
                }
            }
        }
        startTime = [[gregorian dateFromComponents:components] timeIntervalSince1970];
    } else if (self.typeSwitch.selectedSegmentIndex == SpanTypeYear) {
        components.month = 1;
        components.day = 1;
        if (self.offset != 0) {
            components.year = components.year + self.offset;
        }
        startTime = [[gregorian dateFromComponents:components] timeIntervalSince1970];
    }
    
    long endTime = 0;
    if (self.typeSwitch.selectedSegmentIndex == SpanTypeDay) {
        endTime = startTime + 86400;
    } else if (self.typeSwitch.selectedSegmentIndex == SpanTypeWeek) {
        NSInteger numberOfDaysInWeek= 7;
        endTime = startTime + numberOfDaysInWeek*86400;
    } else if (self.typeSwitch.selectedSegmentIndex == SpanTypeMonth) {
        NSRange rng = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[NSDate dateWithTimeIntervalSince1970:startTime]];
        NSInteger numberOfDaysInMonth = rng.length;
        endTime = startTime + numberOfDaysInMonth*86400;
    } else if (self.typeSwitch.selectedSegmentIndex == SpanTypeYear) {
        NSRange rng = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:[NSDate dateWithTimeIntervalSince1970:startTime]];
        NSInteger numberOfDaysIYear = rng.length;
        endTime = startTime + numberOfDaysIYear*86400;
    }
    
    self.data = [MirrorStorage getAllRecordsInTaskOrderWithStart:startTime end:endTime];
    // update label
    NSString *startDate = [MirrorTimeText YYYYmmddWeekday:[NSDate dateWithTimeIntervalSince1970:startTime]];
    NSString *endDate = [MirrorTimeText YYYYmmddWeekday:[NSDate dateWithTimeIntervalSince1970:endTime-1]];// 这里减1是因为，period本身在读的时候取的是左闭右开，例如2023.4.17,Mon,00:00 - 2023.4.19,Wed,00:00间隔为2天，指的就是2023.4.17, 2023.4.18这两天，2023.4.19本身是不做数的。因此这里传日期的时候要减去1，将结束时间2023.4.19,Wed,00:00改为2023.4.18,Wed,23:59，这样传过去的label就只展示左闭右开区间里真实囊括的两天了。
    
    if ([startDate isEqualToString:endDate]) {
        [self updateSpanText:startDate];
    } else {
        startDate = [MirrorTimeText YYYYmmdd:[NSDate dateWithTimeIntervalSince1970:startTime]];
        endDate = [MirrorTimeText YYYYmmdd:[NSDate dateWithTimeIntervalSince1970:endTime-1]];
        NSString *combine  = [[startDate stringByAppendingString:@" - "] stringByAppendingString:endDate];
        [self updateSpanText:combine];
    }
}

- (void)updateSpanText:(NSString *)text
{
    self.dateLabel.text = text;
}

#pragma mark - Getters

- (NSMutableArray<MirrorDataModel *> *)data
{
    if (!_data) {
        _data = [NSMutableArray new];
    }
    return _data;
}

- (UISegmentedControl *)typeSwitch
{
    if (!_typeSwitch) {
        _typeSwitch = [[UISegmentedControl alloc] initWithItems:@[[MirrorLanguage mirror_stringWithKey:@"segment_day"], [MirrorLanguage mirror_stringWithKey:@"segment_week"], [MirrorLanguage mirror_stringWithKey:@"segment_month"], [MirrorLanguage mirror_stringWithKey:@"segment_year"]]];
        _typeSwitch.selectedSegmentIndex = [MirrorSettings spanType];
        [_typeSwitch addTarget:self action:@selector(spanTypeChanged) forControlEvents:UIControlEventValueChanged];
        _typeSwitch.overrideUserInterfaceStyle = [MirrorSettings appliedDarkMode] ? UIUserInterfaceStyleDark : UIUserInterfaceStyleLight;
    }
    return _typeSwitch;
}

- (UIView *)interactionView
{
    if (!_interactionView) {
        _interactionView = [UIView new];
    }
    return _interactionView;
}

- (UILabel *)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [UILabel new];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.text = @"";
        _dateLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:16];
        _dateLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText]; // 和nickname的文字颜色保持一致
    }
    return _dateLabel;
}

- (UIImageView *)leftArrow
{
    if (!_leftArrow) {
        UIImage *image = [[UIImage systemImageNamed:@"chevron.left"] imageWithTintColor:[UIColor mirrorColorNamed:MirrorColorTypeText]];
        UIImage *imageWithRightColor = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _leftArrow = [[UIImageView alloc] initWithImage:imageWithRightColor];
    }
    return _leftArrow;
}

- (UIView *)rightArrow
{
    if (!_rightArrow) {
        UIImage *image = [[UIImage systemImageNamed:@"chevron.right"] imageWithTintColor:[UIColor mirrorColorNamed:MirrorColorTypeText]];
        UIImage *imageWithRightColor = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _rightArrow = [[UIImageView alloc] initWithImage:imageWithRightColor];
    }
    return _rightArrow;
}

- (SpanHistogram *)histogramView
{
    if (!_histogramView) {
        _histogramView = [[SpanHistogram alloc] initWithData:self.data];
        _histogramView.delegate = self.legendView;
    }
    return _histogramView;
}

- (SpanLegend *)legendView
{
    if (!_legendView) {
        _legendView = [[SpanLegend alloc] initWithData:self.data];
    }
    return _legendView;
}

- (MirrorPiechart *)piechartView
{
    if (!_piechartView) {
        _piechartView = [[MirrorPiechart alloc] initWithData:self.data width:MIN([[self leftWidthLeftHeight][0] floatValue], [[self leftWidthLeftHeight][1] floatValue]) enableInteractive:YES];
    }
    return _piechartView;
}

- (UIButton *)settingsButton
{
    if (!_settingsButton) {
        _settingsButton = [UIButton new];
        UIImage *iconImage = [[UIImage systemImageNamed:@"line.horizontal.3"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_settingsButton setImage:[iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_settingsButton addTarget:self action:@selector(goToSettings) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingsButton;
}

- (UIButton *)typeButton
{
    if (!_typeButton) {
        _typeButton = [UIButton new];
        UIImage *iconImage = [[UIImage systemImageNamed:@"checkmark.square"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_typeButton setImage:[iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_typeButton addTarget:self action:@selector(goToHiddenVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return _typeButton;
}

- (UILabel *)emptyHintLabel
{
    if (!_emptyHintLabel) {
        _emptyHintLabel = [UILabel new];
        _emptyHintLabel.textAlignment = NSTextAlignmentCenter;
        _emptyHintLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:16];
        _emptyHintLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeCellGrayPulse]; // 和nickname的文字颜色保持一致
        _emptyHintLabel.text = [MirrorLanguage mirror_stringWithKey:@"no_data"];
        _emptyHintLabel.hidden = self.data.count > 0;
    }
    return _emptyHintLabel;
}

- (void)updateHint
{
    self.emptyHintLabel.text = [MirrorLanguage mirror_stringWithKey:@"no_data"];
    self.emptyHintLabel.hidden = self.data.count > 0;
}

#pragma mark - Animations

// 从左边缘滑动唤起settings
- (void)edgeGestureRecognizerAction:(UIScreenEdgePanGestureRecognizer *)pan
{
    //产生百分比
    CGFloat process = [pan translationInView:self.view].x / (self.view.frame.size.width);
    
    process = MIN(1.0,(MAX(0.0, process)));
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.interactiveTransition = [UIPercentDrivenInteractiveTransition new];
        // 触发present转场动画
        [self goToSettings];
    }else if (pan.state == UIGestureRecognizerStateChanged){
        [self.interactiveTransition updateInteractiveTransition:process];
    }else if (pan.state == UIGestureRecognizerStateEnded
              || pan.state == UIGestureRecognizerStateCancelled){
        if (process > 0.3) {
            [ self.interactiveTransition finishInteractiveTransition];
        }else{
            [ self.interactiveTransition cancelInteractiveTransition];
        }
        self.interactiveTransition = nil;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    if ([presented isKindOfClass:SettingsViewController.class]) { // Settings
        LeftAnimation *animation = [LeftAnimation new];
        animation.isPresent = YES;
        return animation;
    } else { // Hidden VC
        HiddenAnimation *animation = [HiddenAnimation new];
        animation.isPresent = YES;
        animation.buttonFrame = [self.typeButton convertRect:self.typeButton.bounds toView:[[[UIApplication sharedApplication] delegate] window]];
        return animation;
    }
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.interactiveTransition;
}

#pragma mark - Privates

- (NSArray *)leftWidthLeftHeight
{
    CGFloat leftHeight = kScreenHeight - self.navigationController.navigationBar.frame.origin.y - self.navigationController.navigationBar.frame.size.height - 32 -  10 - 60 - 10 - [self.legendView legendViewHeight] - 10 - 20 -  kTabBarHeight;
    CGFloat leftWidth = kScreenWidth - 2*kLeftRightSpacing;

    return @[@(leftWidth), @(leftHeight)];
}


@end
