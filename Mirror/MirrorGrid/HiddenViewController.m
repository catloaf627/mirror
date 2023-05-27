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

@interface HiddenViewController () <UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILabel *singleColorLabel;
@property (nonatomic, strong) UISwitch *toggle;
@property (nonatomic, strong) UIColor *selectedColor;

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
    [self.view addSubview:self.singleColorLabel];
    [self.singleColorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.top.offset(20);
        make.height.mas_equalTo(30);
    }];
    [self.view addSubview:self.toggle];
    [self.toggle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.singleColorLabel.mas_right).offset(10);
        make.top.offset(20);
        make.height.mas_equalTo(30);
    }];
}

#pragma mark - Getters

- (UILabel *)singleColorLabel
{
    if (!_singleColorLabel) {
        _singleColorLabel = [UILabel new];
        _singleColorLabel.text = @"使用单一颜色";
        _singleColorLabel.textAlignment = NSTextAlignmentCenter;
        _singleColorLabel.textColor = self.selectedColor;
        _singleColorLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:15];
    }
    return _singleColorLabel;
}

- (UISwitch *)toggle
{
    if (!_toggle) {
        _toggle = [UISwitch new];
        _toggle.onTintColor = self.selectedColor; // toggle颜色使用pulse
    }
    return _toggle;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:UITapGestureRecognizer.class]) {
        CGPoint touchPoint = [touch locationInView:self.view];
        if (touchPoint.x < self.view.frame.origin.x || touchPoint.y > self.view.frame.origin.y + self.view.frame.size.height) {
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
