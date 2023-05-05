//
//  SettingsPresentAnimator.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/18.
//

#import "SettingsPresentAnimator.h"
#import "MirrorMacro.h"

@implementation SettingsPresentAnimator

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = transitionContext.containerView;
    
    UIView *toView = toVC ? toVC.view : [UIView new];
    
    toView.frame = CGRectMake(-kScreenWidth*0.66, 0, kScreenWidth*0.66, kScreenHeight);
    // 在present和，dismiss时，必须将toview添加到视图层次中
    if ()
    [containerView addSubview:toView];
    CGFloat transitionDuration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:transitionDuration animations:^{
        toView.frame = CGRectMake(0,  0, kScreenWidth*0.66, kScreenHeight);
    }];
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return .45;
}

@end
