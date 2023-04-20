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
#import "DataEntranceCollectionViewCell.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "LeftAnimation.h"
#import "SettingsViewController.h"
#import "SpanHistogram.h"
#import "SpanLegend.h"

static CGFloat const kLeftRightSpacing = 20;

@interface HistoryViewController () <SpanLegendDelegate, SpanHistogramDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;

@property (nonatomic, strong) UISegmentedControl *typeSwitch;
@property (nonatomic, strong) SpanLegend *spanLegend;
@property (nonatomic, strong) SpanHistogram *spanHistogram;

/*
 offset和type一起使用，每次切type的时候置为0。
 offset = n means往右（往未来）拉n周/月/年；offset = -n means往左（往过去）拉n周/月/年；
 */
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UILabel *titleLabel;


@end

@implementation HistoryViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchThemeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchLanguageNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchWeekStartsOnNotification object:nil]; // 比其他vc多监听一个week starts on通知
        
        // 数据通知 (直接数据驱动UI，本地数据变动必然导致这里的UI变动)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskStopNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskEditNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskDeleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskArchiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskCreateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorPeriodDeleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorPeriodEditNotification object:nil];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    [self p_setupUI];
}


- (void)p_setupUI
{
    /*
     If a custom bar button item is not specified by either of the view controllers, a default back button is used and its title is set to the value of the title property of the previous view controller—that is, the view controller one level down on the stack.
     */
    self.navigationController.navigationBar.topItem.title = @""; //给父vc一个空title，让所有子vc的navibar返回文案都为空
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];

    [self.view addSubview:self.typeSwitch];
    [self.typeSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kLeftRightSpacing);
        make.right.mas_equalTo(self.view).offset(-kLeftRightSpacing);
        make.top.mas_equalTo(self.view).offset(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
    }];
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.mas_equalTo(self.typeSwitch.mas_bottom).offset(20);
        make.width.mas_equalTo(2*self.view.frame.size.width/3);
        make.height.mas_equalTo(40);
    }];
    
    [self.view addSubview:self.leftButton];
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.titleLabel.mas_left).offset(-10);
    }];
    [self.view addSubview:self.rightButton];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(10);
    }];
    [self.view addSubview:self.spanLegend];
    [self.spanLegend mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kLeftRightSpacing);
        make.right.mas_equalTo(self.view).offset(-kLeftRightSpacing);
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.height.mas_equalTo([self.spanLegend legendViewHeight]);
    }];
    [self.view addSubview:self.spanHistogram];
    [self.spanHistogram mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kLeftRightSpacing);
        make.right.mas_equalTo(self.view).offset(-kLeftRightSpacing);
        make.top.mas_equalTo(self.spanLegend.mas_bottom);
        make.bottom.mas_equalTo(self.view).offset(-kTabBarHeight - 20);
    }];
    [self.view addSubview:self.settingsButton];
    [self.settingsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kLeftRightSpacing);
        make.bottom.mas_equalTo(self.typeSwitch.mas_top);
        make.width.height.mas_equalTo(40);
    }];
    UIPanGestureRecognizer *panRecognizer = [UIPanGestureRecognizer new];
    [panRecognizer addTarget:self action:@selector(panGestureRecognizerAction:)];
    [self.view addGestureRecognizer:panRecognizer];
    
}


- (void)restartVC
{
    // 将vc.view里的所有subviews全部置为nil
    self.settingsButton = nil;
    self.typeSwitch = nil;
    // 将vc.view里的所有subviews从父view上移除
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 更新tabbar
    [[MirrorTabsManager sharedInstance] updateHistoryTabItemWithTabController:self.tabBarController];
    [self viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)reloadData
{
    // 当页面没有出现在屏幕上的时候reloaddata不会触发UICollectionViewDataSource的几个方法，所以需要上面viewWillAppear做一个兜底。
    
}

#pragma mark - Actions

- (void)clickLeft
{
    self.offset = self.offset - 1;
    [self.spanLegend updateWithSpanType:self.typeSwitch.selectedSegmentIndex offset:self.offset];
    [self.spanHistogram updateWithSpanType:self.typeSwitch.selectedSegmentIndex offset:self.offset];
    self.titleLabel.text = [[self.spanHistogram.startDate stringByAppendingString:@" - "] stringByAppendingString:self.spanHistogram.endDate];
}

- (void)clickRight
{
    self.offset = self.offset + 1;
    [self.spanLegend updateWithSpanType:self.typeSwitch.selectedSegmentIndex offset:self.offset];
    [self.spanHistogram updateWithSpanType:self.typeSwitch.selectedSegmentIndex offset:self.offset];
    self.titleLabel.text = [[self.spanHistogram.startDate stringByAppendingString:@" - "] stringByAppendingString:self.spanHistogram.endDate];
}

- (void)spanTypeChanged
{
    [self.spanHistogram updateWithSpanType:self.typeSwitch.selectedSegmentIndex offset:self.offset];
    self.titleLabel.text = [[self.spanHistogram.startDate stringByAppendingString:@" - "] stringByAppendingString:self.spanHistogram.endDate];
}

#pragma mark - Getters

- (UISegmentedControl *)typeSwitch
{
    if (!_typeSwitch) {
        _typeSwitch = [[UISegmentedControl alloc] initWithItems:@[@"Week", @"Month", @"Year"]];
        _typeSwitch.selectedSegmentIndex = 0;
        [_typeSwitch addTarget:self action:@selector(spanTypeChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _typeSwitch;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"gizmo";
        _titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:16];
        _titleLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeCellGrayPulse]; // 和nickname的文字颜色保持一致
    }
    return _titleLabel;
}

- (UIButton *)leftButton
{
    if (!_leftButton) {
        _leftButton = [UIButton new];
        UIImage *iconImage = [[UIImage systemImageNamed:@"chevron.left"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_leftButton setImage:[iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _leftButton.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_leftButton addTarget:self action:@selector(clickLeft) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (UIButton *)rightButton
{
    if (!_rightButton) {
        _rightButton = [UIButton new];
        UIImage *iconImage = [[UIImage systemImageNamed:@"chevron.right"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_rightButton setImage:[iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _rightButton.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_rightButton addTarget:self action:@selector(clickRight) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

- (SpanHistogram *)spanHistogram
{
    if (!_spanHistogram) {
        _spanHistogram = [[SpanHistogram alloc] initWithSpanType:self.typeSwitch.selectedSegmentIndex offset:self.offset];
        _spanHistogram.delegate = self;
    }
    return _spanHistogram;
}

- (SpanLegend *)spanLegend
{
    if (!_spanLegend) {
        _spanLegend = [[SpanLegend alloc] initWithSpanType:self.typeSwitch.selectedSegmentIndex offset:self.offset];
        _spanLegend.delegate = self;
    }
    return _spanLegend;
}

- (UIButton *)settingsButton
{
    if (!_settingsButton) {
        _settingsButton = [UIButton new];
        UIImage *iconImage = [[UIImage systemImageNamed:@"ellipsis"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_settingsButton setImage:[iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _settingsButton.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_settingsButton addTarget:self action:@selector(goToSettings) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingsButton;
}

#pragma mark - Settings

- (void)goToSettings
{
    [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight] impactOccurred];
    SettingsViewController * settingsVC = [[SettingsViewController alloc] init];
    settingsVC.transitioningDelegate = self;
    settingsVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:settingsVC animated:YES completion:nil];
}

// 从左边缘滑动唤起settings
- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)pan
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
