//
//  MSNavigationController.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSNavigationController.h"
#import "MSBaseViewController.h"

#import "QBCustomPushAnimation.h"

@interface MSNavigationController () <UINavigationBarDelegate>
@property (nonatomic) QBCustomPushAnimation *pushAnimation;
@end

@implementation MSNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:18.],
                                               NSForegroundColorAttributeName : [UIColor whiteColor]};
    [self.navigationBar setTintColor:kColor(@"#ffffff")];
    [self.navigationBar setBackIndicatorImage:[UIImage imageNamed:@"back"]];
    [self.navigationBar setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"back"]];
    
    UIImage *barBackgroundImg = [self.navigationBar setGradientWithSize:CGSizeMake(kScreenWidth, 64) Colors:@[kColor(@"#EF6FB0"),kColor(@"#ED455C")] direction:leftToRight];
    [self.navigationBar setBackgroundImage:barBackgroundImg forBarMetrics:UIBarMetricsDefault];
        
    self.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    self.delegate = (id<UINavigationControllerDelegate>)self;
    
}

- (QBCustomPushAnimation *)pushAnimation {
    if (!_pushAnimation) {
        _pushAnimation = [[QBCustomPushAnimation alloc] init];
    }
    return _pushAnimation;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.visibleViewController.preferredStatusBarStyle;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    BOOL alwaysHideNavigationBar = NO;
    if ([viewController isKindOfClass:[MSBaseViewController class]]) {
        alwaysHideNavigationBar = ((MSBaseViewController *)viewController).alwaysHideNavigationBar;
    }
    
    if (self.navigationBarHidden != alwaysHideNavigationBar) {
        [self setNavigationBarHidden:alwaysHideNavigationBar animated:animated];
    }
}

//- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
//                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController NS_AVAILABLE_IOS(7_0) {
//    return nil;
//}
//
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC  NS_AVAILABLE_IOS(7_0)
{
    if(operation == UINavigationControllerOperationPush) {
//        return self.pushAnimation;
    }
    return nil;
}

@end
