//
//  CellAnimation.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/24.
//

#import "CellAnimation.h"

@implementation CellAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return .3f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView* toView = nil;
    UIView* fromView = nil;
    UIView* transView = nil;
    
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        fromView = fromViewController.view;
        toView = toViewController.view;
    }
    
    if (_isPresent) {  // present
        transView = toView;
        [[transitionContext containerView] addSubview:toView];
        
    } else {  // dismiss
        transView = fromView;
        [[transitionContext containerView] insertSubview:toView belowSubview:fromView];
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    if (_isPresent) { // present
        transView.frame = self.cellFrame;
        transView.layer.cornerRadius = 14; // cell radius
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            transView.frame = CGRectMake(0, 0, width, height);
            transView.layer.cornerRadius = 0;
        } completion:^(BOOL finished) {
             [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    } else { // dismiss
        transView.frame = CGRectMake(0, 0, width, height);
        transView.layer.cornerRadius = 0;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            transView.frame = self.cellFrame;
            transView.layer.cornerRadius = 14; // cell radius
        } completion:^(BOOL finished) {
             [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
}


@end
