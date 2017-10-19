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

//- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
//    if ([self navigationControllerOperation] == UINavigationControllerOperationPush) {
//        [self customAnimatePushTransition:transitionContext];
//    } else {
//        [self customAnimatePopTransition:transitionContext];
//    }
//}
//
//- (UIView *)snapShotOfViewController:(UIViewController *)viewControlelr {
//    if (viewControlelr.navigationController) {
//        UIView *snapShot = [viewControlelr.navigationController.view snapshotViewAfterScreenUpdates:NO];
//        return snapShot;
//    }
//    return nil;
//}
//
//- (void)customAnimatePushTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
//    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    UIViewController *toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    NSTimeInterval duration = [self transitionDuration:transitionContext];
//
//    CGRect initialFrame = [[fromViewController view] frame];
//    CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];
//    UINavigationBar *navigationBar = [[fromViewController navigationController] navigationBar];
//    CGRect navigationBarFrame = [navigationBar frame];
//
//    navigationBar.frame = CGRectOffset(navigationBarFrame, CGRectGetWidth(navigationBarFrame), 0);
//    toViewController.view.frame = CGRectOffset(finalFrame, CGRectGetWidth(finalFrame), 0);
//
//    [[transitionContext containerView] addSubview:[fromViewController snapshot]];
//    [[transitionContext containerView] addSubview:[toViewController view]];
//
//    fromViewController.view.hidden = YES;
//    UIApplication.sharedApplication.delegate.window.backgroundColor = [UIColor blackColor];
//
//    [UIView animateWithDuration:duration
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         fromViewController.snapshot.alpha = 0.5;
//                         fromViewController.snapshot.frame = CGRectInset(initialFrame, 20, 20);
//                         toViewController.view.frame = finalFrame;
//                         navigationBar.frame = navigationBarFrame;
//                     }
//                     completion:^(BOOL finished) {
//                         fromViewController.view.hidden = NO;
//                         fromViewController.snapshot.frame = CGRectInset(initialFrame, 20, 20);
//
//                         toViewController.view.frame = finalFrame;
//                         navigationBar.frame = navigationBarFrame;
//
//                         UIApplication.sharedApplication.delegate.window.backgroundColor = [UIColor whiteColor];
//
//                         [[fromViewController snapshot] removeFromSuperview];
//
//                         [transitionContext completeTransition:YES];
//                     }];
//}
//
//- (void)customAnimatePopTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
//    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    UIViewController *toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    NSTimeInterval duration = [self transitionDuration:transitionContext];
//
//    CGRect initialFrame = [[fromViewController view] frame];
//    CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];
//
//    toViewController.view.hidden = YES;
//    toViewController.snapshot.alpha = 0.5;
//    toViewController.snapshot.frame = CGRectInset(finalFrame, 20, 20);
//
//    fromViewController.navigationController.navigationBar.hidden = YES;
//    UIApplication.sharedApplication.delegate.window.backgroundColor = [UIColor blackColor];
//
//    [[fromViewController view] addSubview:[fromViewController snapshot]];
//    [[transitionContext containerView] addSubview:[toViewController view]];
//    [[transitionContext containerView] addSubview:[toViewController snapshot]];
//    [[transitionContext containerView] sendSubviewToBack:[toViewController snapshot]];
//
//    [UIView animateWithDuration:duration
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveLinear
//                     animations:^{
//                         fromViewController.view.frame = CGRectOffset(initialFrame, CGRectGetWidth(initialFrame), 0);
//                         toViewController.snapshot.alpha = 1.0;
//                         toViewController.snapshot.frame = finalFrame;
//                     }
//                     completion:^(BOOL finished) {
//                         toViewController.view.hidden = NO;
//                         toViewController.navigationController.navigationBar.hidden = NO;
//                         UIApplication.sharedApplication.delegate.window.backgroundColor = [UIColor whiteColor];
//
//                         [[fromViewController snapshot] removeFromSuperview];
//                         [[toViewController snapshot] removeFromSuperview];
//
//                         // Reset toViewController's `snapshot` to nil
//                         if (![transitionContext transitionWasCancelled]) {
//                             toViewController.snapshot = nil;
//                         }
//
//                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//                     }];
//
//}

@end
