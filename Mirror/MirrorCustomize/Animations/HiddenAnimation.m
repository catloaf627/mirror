//
//  HiddenAnimation.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/27.
//

#import "HiddenAnimation.h"

@implementation HiddenAnimation

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
    CGFloat width = 2*[UIScreen mainScreen].bounds.size.width/3;
    CGFloat height = [UIScreen mainScreen].bounds.size.height/2;
    if (_isPresent) { // present
        transView.frame = self.buttonFrame;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            transView.frame = CGRectMake(self.buttonFrame.origin.x-(width-self.buttonFrame.size.width), self.buttonFrame.origin.y, width, height);
        } completion:^(BOOL finished) {
             [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    } else { // dismiss
        transView.frame = CGRectMake(self.buttonFrame.origin.x-(width-self.buttonFrame.size.width), self.buttonFrame.origin.y, width, height);
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            transView.frame = self.buttonFrame;
        } completion:^(BOOL finished) {
             [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
}

@end
