//
//  SettingsDissolveAnimator.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/18.
//

#import "SettingsDissolveAnimator.h"
#import "MirrorMacro.h"
@implementation SettingsDissolveAnimator

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {

    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = transitionContext.containerView;
    
    UIView *fromView = fromVC ? fromVC.view : [UIView new];
    UIView *toView = toVC ? toVC.view : [UIView new];
    
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    }
    toView.frame = CGRectMake(0,  0, kScreenWidth*0.66, kScreenHeight);
    // 在present和，dismiss时，必须将toview添加到视图层次中
    [containerView addSubview:toView];
    CGFloat transitionDuration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:transitionDuration animations:^{
        toView.frame = CGRectMake(-kScreenWidth*0.66, 0, kScreenWidth*0.66, kScreenHeight);
    }];

}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 2.0;
}

@end
