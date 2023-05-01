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

static CGFloat const kLeftRightSpacing = 20;

@interface HistoryViewController () <SpanLegendDelegate, SpanHistogramDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;

@property (nonatomic, strong) UISegmentedControl *typeSwitch;
@property (nonatomic, strong) SpanLegend *legendView;
@property (nonatomic, strong) SpanHistogram *histogramView;

/*
 offset和type一起使用，每次切type的时候置为0。
 offset = n means往右（往未来）拉n周/月/年；offset = -n means往左（往过去）拉n周/月/年；
 */
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) UIView *interactionView; //在这个view的范围内，点左侧offset-1,点右侧offset+1
@property (nonatomic, strong) UIImageView *leftArrow;
@property (nonatomic, strong) UIImageView *rightArrow;
@property (nonatomic, strong) UILabel *titleLabel;


@end

@implementation HistoryViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 设置通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchThemeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchLanguageNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchWeekStartsOnNotification object:nil]; // 比其他vc多监听一个week starts on通知
        
        // 数据通知 (直接数据驱动UI，本地数据变动必然导致这里的UI变动) 
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

- (void)restartVC
{
    // 将vc.view里的所有subviews全部置为nil
    self.typeSwitch = nil;
    self.interactionView = nil;
    self.leftArrow = nil;
    self.rightArrow = nil;
    self.titleLabel = nil;
    self.legendView = nil;
    self.histogramView = nil;
    // 将vc.view里的所有subviews从父view上移除
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 更新tabbar 和 navibar
    [[MirrorTabsManager sharedInstance] updateHistoryTabItemWithTabController:self.tabBarController];
    if (self.tabBarController.selectedIndex == 2) {
        [[MirrorNaviManager sharedInstance] updateNaviItemWithNaviController:self.navigationController title:@"" leftButton:self.settingsButton rightButton:nil];
    }
    [self p_setupUI];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_setupUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[MirrorNaviManager sharedInstance] updateNaviItemWithNaviController:self.navigationController title:@"" leftButton:self.settingsButton rightButton:nil];
}

- (void)reloadData
{
    [self.legendView updateWithSpanType:self.typeSwitch.selectedSegmentIndex offset:self.offset];
    [self.legendView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([self.legendView legendViewHeight]);
    }];
    [self.histogramView updateWithSpanType:self.typeSwitch.selectedSegmentIndex offset:self.offset];
}

- (void)p_setupUI
{
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    
    [self.view addSubview:self.typeSwitch];
    [self.typeSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kLeftRightSpacing);
        make.right.mas_equalTo(self.view).offset(-kLeftRightSpacing);
        make.top.mas_equalTo(self.view).offset(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
    }];

    [self.view addSubview:self.interactionView];
    [self.interactionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.typeSwitch.mas_bottom).offset(10);
        make.height.mas_equalTo(60);
    }];
    [self.interactionView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.offset(0);
        make.width.mas_equalTo(2*self.view.frame.size.width/3);
        make.height.mas_equalTo(40);
    }];
    [self.interactionView addSubview:self.leftArrow];
    [self.leftArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.titleLabel.mas_left).offset(-10);
    }];
    [self.interactionView addSubview:self.rightArrow];
    [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(10);
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
    
    UITapGestureRecognizer *tapRecognizer = [UITapGestureRecognizer new];
    [tapRecognizer addTarget:self action:@selector(tapGestureRecognizerAction:)];
    [self.interactionView addGestureRecognizer:tapRecognizer];
    
    UIScreenEdgePanGestureRecognizer *edgeRecognizer = [UIScreenEdgePanGestureRecognizer new];
    edgeRecognizer.edges = UIRectEdgeLeft;
    [edgeRecognizer addTarget:self action:@selector(edgeGestureRecognizerAction:)];
    [self.view addGestureRecognizer:edgeRecognizer];
    
}


#pragma mark - Actions

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


#pragma mark - SpanHistogramDelegate

- (void)updateSpanText:(NSString *)text
{
    self.titleLabel.text = text;
}

#pragma mark - Getters

- (UISegmentedControl *)typeSwitch
{
    if (!_typeSwitch) {
        _typeSwitch = [[UISegmentedControl alloc] initWithItems:@[[MirrorLanguage mirror_stringWithKey:@"segment_day"], [MirrorLanguage mirror_stringWithKey:@"segment_week"], [MirrorLanguage mirror_stringWithKey:@"segment_month"], [MirrorLanguage mirror_stringWithKey:@"segment_year"]]];
        _typeSwitch.selectedSegmentIndex = 0;
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

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"";
        _titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:16];
        _titleLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText]; // 和nickname的文字颜色保持一致
    }
    return _titleLabel;
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
        _histogramView = [[SpanHistogram alloc] initWithSpanType:self.typeSwitch.selectedSegmentIndex offset:self.offset];
        _histogramView.delegate = self;
    }
    return _histogramView;
}

- (SpanLegend *)legendView
{
    if (!_legendView) {
        _legendView = [[SpanLegend alloc] initWithSpanType:self.typeSwitch.selectedSegmentIndex offset:self.offset];
        _legendView.delegate = self;
    }
    return _legendView;
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

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    LeftAnimation *animation = [LeftAnimation new];
    animation.isPresent = YES;
    return animation;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.interactiveTransition;
}


@end
