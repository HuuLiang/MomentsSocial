//
//  MSTabBarController.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSTabBarController.h"
#import "MSNavigationController.h"
#import "MSHomeViewController.h"
#import "MSDiscoverViewController.h"
#import "MSContactViewController.h"
#import "MSMineViewController.h"

@interface MSTabBarController () <UITabBarControllerDelegate>

@end

@implementation MSTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setChildViewControllers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
}



- (void)setChildViewControllers {
    MSHomeViewController *homeVC = [[MSHomeViewController alloc] initWithTitle:@"首页"];
    MSNavigationController *homeNav = [[MSNavigationController alloc] initWithRootViewController:homeVC];
    homeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:homeVC.title
                                                         image:[[UIImage imageNamed:@"home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ]
                                                 selectedImage:[[UIImage imageNamed:@"home_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    MSDiscoverViewController *discoverVC = [[MSDiscoverViewController alloc] initWithTitle:@"发现"];
    MSNavigationController *discoverNav = [[MSNavigationController alloc] initWithRootViewController:discoverVC];
    discoverNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:discoverVC.title
                                                           image:[[UIImage imageNamed:@"discover_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ]
                                                   selectedImage:[[UIImage imageNamed:@"discover_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    
    MSContactViewController *contactVC = [[MSContactViewController alloc] initWithTitle:@"消息"];
    MSNavigationController *contactNav = [[MSNavigationController alloc] initWithRootViewController:contactVC];
    contactNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:contactVC.title
                                                          image:[[UIImage imageNamed:@"contact_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                  selectedImage:[[UIImage imageNamed:@"contact_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    MSMineViewController *mineVC = [[MSMineViewController alloc] initWithTitle:@"我的"];
    MSNavigationController *mineNav = [[MSNavigationController alloc] initWithRootViewController:mineVC];
    mineNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:mineVC.title
                                                       image:[[UIImage imageNamed:@"mine_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                               selectedImage:[[UIImage imageNamed:@"mine_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    
    self.tabBar.translucent = NO;
    self.viewControllers = @[homeNav,discoverNav,contactNav,mineNav];
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
}

@end
