//
//  AppDelegate+Configurations.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (Configurations)
- (void)checkNetworkInfoState;
- (void)setCommonStyle;
- (void)showHomeViewController;

- (void)checkLocalNotificationWithLaunchOptionsOptions:(NSDictionary *)launchOptions;

@end
