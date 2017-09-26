//
//  AppDelegate+Configurations.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "AppDelegate+Configurations.h"
#import "QBNetworkInfo.h"
#import "MSReqManager.h"
#import "MSTabBarController.h"
#import "MSActivityModel.h"
#import "MSSystemConfigModel.h"
#import <UMMobClick/MobClick.h>
#import "QBUploadManager.h"
#import "MSAutoReplyMessageManager.h"
#import "QBLocationManager.h"
#import "MSPaymentManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate (Configurations)

- (void)checkNetworkInfoState {
    
    [[QBNetworkInfo sharedInfo] startMonitoring];
    
    [QBNetworkInfo sharedInfo].reachabilityChangedAction = ^ (BOOL reachable) {
        
        if (reachable && [MSUtil isRegisteredUUID]) {
            [self showHomeViewController];
        } else {
            [self registerUUID];
        }
        
        //网络错误提示
        if ([QBNetworkInfo sharedInfo].networkStatus <= QBNetworkStatusNotReachable && (![MSUtil isRegisteredUUID])) {
            if (!@available(iOS 11, *)) {
                if ([MSUtil isIpad]) {
                    [UIAlertView bk_showAlertViewWithTitle:@"请检查您的网络连接!" message:nil cancelButtonTitle:@"确认" otherButtonTitles:nil handler:nil];
                }else{
                    [UIAlertView bk_showAlertViewWithTitle:@"很抱歉!" message:@"您的应用未连接到网络,请检查您的网络设置" cancelButtonTitle:@"稍后" otherButtonTitles:@[@"设置"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 1) {
                            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            if([[UIApplication sharedApplication] canOpenURL:url]) {
                                [[UIApplication sharedApplication] openURL:url];
                            }
                        }
                    }];
                }
            }
        }
    };
}

- (void)registerUUID {
    [[MSReqManager manager] registerUUIDClass:[MSActivityModel class] completionHandler:^(BOOL success, MSActivityModel * response) {
        if (success) {
            [MSUtil setRegisteredWithUUID:response.uuid];
            [MSUtil registerUserId:response.userId];
            [MSUtil registerNickName:response.nickName];
            [MSUtil registerPortraitUrl:response.portraitUrl];
            [self showHomeViewController];
        }
    }];
}

- (void)fetchSystemConfigInfo {
    [[MSReqManager manager] fetchSystemConfigInfoClass:[MSSystemConfigModel class] completionHandler:^(BOOL success, MSSystemConfigModel * obj) {
        if (success) {
            [MSSystemConfigModel defaultConfig].config = obj.config;
            [[MSSystemConfigModel defaultConfig] configPayInfoWithConfig:obj.config];
            
            [[MSAutoReplyMessageManager manager] startAutoReplyMsgEvent];
        }
    }];
}

- (void)setupMobStatistics {
#ifdef DEBUG
    [MobClick setLogEnabled:YES];
#endif
    if (XcodeAppVersion) {
        [MobClick setAppVersion:XcodeAppVersion];
    }
    UMConfigInstance.appKey = MS_UMENG_APP_ID;
    UMConfigInstance.channelId = MS_CHANNEL_NO;
    [MobClick startWithConfigure:UMConfigInstance];
}

- (void)setCommonStyle {
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithHexString:@"#ffffff"]];
    [[UITabBar appearance] setTintColor:[UIColor redColor]];
    [[UITabBar appearance] setBarStyle:UIBarStyleBlack];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:kColor(@"#999999"),NSFontAttributeName:kFont(11)} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:kColor(@"#ED465C"),NSFontAttributeName:kFont(11)} forState:UIControlStateSelected];
    
    [UITabBarController aspect_hookSelector:@selector(shouldAutorotate)
                                withOptions:AspectPositionInstead
                                 usingBlock:^(id<AspectInfo> aspectInfo){
                                     UITabBarController *thisTabBarVC = [aspectInfo instance];
                                     UIViewController *selectedVC = thisTabBarVC.selectedViewController;
                                     
                                     BOOL autoRotate = NO;
                                     if ([selectedVC isKindOfClass:[UINavigationController class]]) {
                                         autoRotate = [((UINavigationController *)selectedVC).topViewController shouldAutorotate];
                                     } else {
                                         autoRotate = [selectedVC shouldAutorotate];
                                     }
                                     [[aspectInfo originalInvocation] setReturnValue:&autoRotate];
                                 } error:nil];
    
    [UIViewController aspect_hookSelector:@selector(viewDidLoad)
                              withOptions:AspectPositionAfter
                               usingBlock:^(id<AspectInfo> aspectInfo){
                                   UIViewController *thisVC = [aspectInfo instance];
                                   if (thisVC.navigationController.viewControllers.count > 0) {
                                       UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
                                       backItem.title = @"";
                                       thisVC.navigationItem.backBarButtonItem = backItem;
                                   }
                                   thisVC.navigationController.navigationBar.translucent = NO;
                               } error:nil];
    
    [UITabBarController aspect_hookSelector:@selector(supportedInterfaceOrientations)
                                withOptions:AspectPositionInstead
                                 usingBlock:^(id<AspectInfo> aspectInfo){
                                     UITabBarController *thisTabBarVC = [aspectInfo instance];
                                     UIViewController *selectedVC = thisTabBarVC.selectedViewController;
                                     
                                     NSUInteger result = 0;
                                     if ([selectedVC isKindOfClass:[UINavigationController class]]) {
                                         result = [((UINavigationController *)selectedVC).topViewController supportedInterfaceOrientations];
                                     } else {
                                         result = [selectedVC supportedInterfaceOrientations];
                                     }
                                     [[aspectInfo originalInvocation] setReturnValue:&result];
                                 } error:nil];
    
    [UIViewController aspect_hookSelector:@selector(hidesBottomBarWhenPushed)
                              withOptions:AspectPositionInstead
                               usingBlock:^(id<AspectInfo> aspectInfo)
     {
         UIViewController *thisVC = [aspectInfo instance];
         BOOL hidesBottomBar = NO;
         if (thisVC.navigationController.viewControllers.count > 1) {
             hidesBottomBar = YES;
         }
         [[aspectInfo originalInvocation] setReturnValue:&hidesBottomBar];
     } error:nil];
    
    [UIScrollView aspect_hookSelector:@selector(showsVerticalScrollIndicator)
                          withOptions:AspectPositionInstead
                           usingBlock:^(id<AspectInfo> aspectInfo)
     {
         BOOL bShow = NO;
         [[aspectInfo originalInvocation] setReturnValue:&bShow];
     } error:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[MSPaymentManager manager] applicationWillEnterForeground:application];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [[MSPaymentManager manager] handleOpenURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [[MSPaymentManager manager] handleOpenURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[MSPaymentManager manager] handleOpenURL:url];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
//    if ([[notification.userInfo.allKeys firstObject] isEqualToString:kMSAutoNotificationTypeKeyName]) {
//        [[MSAutoReplyMessageManager manager] fetchOneReplyUserInfo];
//    }
//    [application setApplicationIconBadgeNumber:[[YFBContactManager manager] allUnReadMessageCount]];
}

- (void)checkLocalNotificationWithLaunchOptionsOptions:(NSDictionary *)launchOptions {
//    UILocalNotification *localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
//    if (!localNotification) {
//        return;
//    }
//    if ([[localNotification.userInfo.allKeys firstObject] isEqualToString:kMSAutoNotificationTypeKeyName]) {
//        [[MSAutoReplyMessageManager manager] fetchOneReplyUserInfo];
//    }
}


- (void)showHomeViewController {
    //设置默认配置信息  微信注册 友盟统计  七牛注册  系统配置 开启推送 定位
    [[MSPaymentManager manager] setup];
    [self setupMobStatistics];
    [QBUploadManager registerWithSecretKey:MS_UPLOAD_SECRET_KEY accessKey:MS_UPLOAD_ACCESS_KEY scope:MS_UPLOAD_SCOPE];

    [self fetchSystemConfigInfo];
    
    [[QBLocationManager manager] loadLocationManager];
    
    [MSUtil addCheckLoginCount];  //活动相关
    
    MSTabBarController *tabBarVC = [[MSTabBarController alloc] init];
    self.window.rootViewController = tabBarVC;
    [self.window makeKeyAndVisible];
}

@end
