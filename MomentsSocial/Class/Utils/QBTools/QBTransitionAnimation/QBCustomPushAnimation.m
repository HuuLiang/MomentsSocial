//
//  QBCustomPushAnimation.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/15.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "QBCustomPushAnimation.h"
#import "MSBaseViewController.h"
#import "MSNavigationController.h"

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
    UIImageView *imgV = [[UIImageView alloc] init];
    if ([toViewController.navigationController isKindOfClass:[MSNavigationController class]]) {
        toViewController = (MSNavigationController *)toViewController.navigationController;
        
    }
    
    if ([fromViewController.navigationController isKindOfClass:[MSNavigationController class]]) {
        fromViewController = (MSNavigationController *)fromViewController.navigationController;
    }
    if (![toViewController isKindOfClass:[MSNavigationController class]]) {
    }
    toViewController.view.frame = CGRectMake(0, height, QBScreenWidth, QBScreenHeight);

    
    toViewController.view.transform = CGAffineTransformMakeTranslation(QBScreenWidth, 0);
    
    UIView *shadowView = [[UIView alloc] initWithFrame:fromViewController.view.frame];
    shadowView.backgroundColor = kColor(@"#000000");
    shadowView.alpha = 0.0f;
    [[transitionContext containerView] insertSubview:shadowView belowSubview:toViewController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromViewController.view.transform = CGAffineTransformMakeScale(0.95, 0.95);
        shadowView.alpha = 0.6f;
        toViewController.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [shadowView removeFromSuperview];
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (UIImage *)makeImageWithView:(UIView *)view

{
    CGSize s = view.bounds.size;
    
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了，关键就是第三个参数。
    
    UIGraphicsBeginImageContextWithOptions(s, YES, [UIScreen mainScreen].scale);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

@end
