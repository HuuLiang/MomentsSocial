//
//  QBCustomPushAnimation.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/15.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "QBCustomPushAnimation.h"
#import "MSBaseViewController.h"

#define QBScreenWidth      [ [ UIScreen mainScreen ] bounds ].size.width
#define QBScreenHeight     [ [ UIScreen mainScreen ] bounds ].size.height



@implementation QBCustomPushAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [[transitionContext containerView] insertSubview:toViewController.view aboveSubview:fromViewController.view];
    
    CGFloat height = 64;
    if ([toViewController isKindOfClass:[MSBaseViewController class]]) {
        if (((MSBaseViewController *)toViewController).alwaysHideNavigationBar) {
            height = 0;
        };
    }
    
    toViewController.view.frame = CGRectMake(0, height, QBScreenWidth, QBScreenHeight);
    toViewController.view.transform = CGAffineTransformMakeTranslation(QBScreenWidth, 0);
    
    UIView *shadowView = [[UIView alloc] initWithFrame:fromViewController.view.frame];
    shadowView.backgroundColor = kColor(@"#000000");
    shadowView.alpha = 0.0f;
    [[transitionContext containerView] insertSubview:shadowView belowSubview:toViewController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//        fromViewController.view.transform = CGAffineTransformMakeTranslation(-QBScreenWidth, 0);
        fromViewController.view.transform = CGAffineTransformMakeScale(0.95, 0.95);
        shadowView.alpha = 0.6f;
        toViewController.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [shadowView removeFromSuperview];
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
