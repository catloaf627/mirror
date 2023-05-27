//
//  HiddenViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/27.
//

#import "HiddenViewController.h"
#import "HiddenAnimation.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "MirrorSettings.h"
@interface HiddenViewController () <UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *singleColorButton;
@property (nonatomic, strong) UIButton *pieChartButton;

@end

@implementation HiddenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    self.view.layer.cornerRadius = 14;
    self.view.layer.borderColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint].CGColor;
    self.view.layer.borderWidth = 1;
    
    [self p_setupUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 手势(点击外部dismiss)
    UITapGestureRecognizer *tapRecognizer = [UITapGestureRecognizer new];
    tapRecognizer.delegate = self;
    [self.view.superview addGestureRecognizer:tapRecognizer];
    // 动画
    self.transitioningDelegate = self;
}


- (void)p_setupUI
{
    [self.view addSubview:self.singleColorButton];
    [self.singleColorButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.top.offset(20);
        make.width.height.mas_equalTo(30);
    }];
    [self.view addSubview:self.pieChartButton];
    [self.pieChartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.singleColorButton.mas_right).offset(10);
        make.top.offset(20);
        make.width.height.mas_equalTo(30);
    }];
    
}

#pragma mark - Actions

- (void)singleColorSwitchChanged
{
    // 本地保存
    [MirrorSettings switchShowShade];
    NSArray *allColorType = @[@(MirrorColorTypeCellPinkPulse), @(MirrorColorTypeCellOrangePulse), @(MirrorColorTypeCellYellowPulse), @(MirrorColorTypeCellGreenPulse), @(MirrorColorTypeCellTealPulse), @(MirrorColorTypeCellBluePulse), @(MirrorColorTypeCellPurplePulse),@(MirrorColorTypeCellGrayPulse)];
    NSInteger randomColorType = [allColorType[arc4random() % allColorType.count] integerValue]; // 随机生成一个颜色（都是pulse色！不然叠上透明度就看不清了）
    [MirrorSettings changePreferredShadeColor:randomColorType];
    // update button
    NSString *iconName = [MirrorSettings appliedShowShade] ? @"square.grid.2x2.fill" : @"square.grid.2x2";
    UIImage *iconImage = [[UIImage systemImageNamed:iconName]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [_singleColorButton setImage:[iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
}

- (void)usePieChartSwitchChanged
{
    // 本地保存
    [MirrorSettings switchChartType];
    // update button
    NSString *iconName = [MirrorSettings appliedPieChart] ? @"chart.pie.fill" : @"chart.pie";
    UIImage *iconImage = [[UIImage systemImageNamed:iconName]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [_pieChartButton setImage:[iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
}

#pragma mark - Getters

- (UIButton *)singleColorButton
{
    if (!_singleColorButton) {
        _singleColorButton = [UIButton new];
        NSString *iconName = [MirrorSettings appliedShowShade] ? @"square.grid.2x2.fill" : @"square.grid.2x2";
        UIImage *iconImage = [[UIImage systemImageNamed:iconName]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_singleColorButton setImage:[iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _singleColorButton.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_singleColorButton addTarget:self action:@selector(singleColorSwitchChanged) forControlEvents:UIControlEventTouchUpInside];
    }
    return _singleColorButton;
}

- (UIButton *)pieChartButton
{
    if (!_pieChartButton) {
        _pieChartButton = [UIButton new];
        NSString *iconName = [MirrorSettings appliedPieChart] ? @"chart.pie.fill" : @"chart.pie";
        UIImage *iconImage = [[UIImage systemImageNamed:iconName]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_pieChartButton setImage:[iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _pieChartButton.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_pieChartButton addTarget:self action:@selector(usePieChartSwitchChanged) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pieChartButton;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:UITapGestureRecognizer.class]) {
        CGPoint touchPoint = [touch locationInView:self.view];
        if (touchPoint.x<0 || touchPoint.y>self.view.frame.origin.y + self.view.frame.size.height) {
            [self dismissViewControllerAnimated:YES completion:nil];// 点了view外面
        } else {
            // 点了view里面
        }
    }
    return NO;
}


#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    HiddenAnimation *animation = [HiddenAnimation new];
    animation.isPresent = NO;
    animation.buttonFrame = self.buttonFrame;
    return animation;
}


@end
