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
#import <WXApi.h>
#import <AlipaySDK/AlipaySDK.h>
#import "AlipayManager.h"
#import "WeChatPayManager.h"
#import <UMMobClick/MobClick.h>
#import "QBUploadManager.h"

@interface AppDelegate () <WXApiDelegate>

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
    };
}

- (void)registerUUID {
    [[MSReqManager manager] registerUUIDClass:[MSActivityModel class] completionHandler:^(BOOL success, MSActivityModel * response) {
        if (success) {
            [MSUtil setRegisteredWithUUID:response.uuid];
            [MSUtil registerUserId:response.userId];
            [self showHomeViewController];
        }
    }];
}

- (void)fetchSystemConfigInfo {
    [[MSReqManager manager] fetchSystemConfigInfoClass:[MSSystemConfigModel class] completionHandler:^(BOOL success, MSSystemConfigModel * obj) {
        if (success) {
            [MSSystemConfigModel defaultConfig].config = obj.config;
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        [[AlipayManager shareInstance] sendNotificationByResult:resultDic];
    }];
    [WXApi handleOpenURL:url delegate:(id<WXApiDelegate>)self];
    return YES;
}

- (void)showHomeViewController {
    //设置默认配置信息  微信注册  七牛注册  加载钻石 礼物信息
    [WXApi registerApp:MS_WEXIN_APP_ID];
    [self setupMobStatistics];
    [QBUploadManager registerWithSecretKey:MS_UPLOAD_SECRET_KEY accessKey:MS_UPLOAD_ACCESS_KEY scope:MS_UPLOAD_SCOPE];

    [self fetchSystemConfigInfo];
    
    MSTabBarController *tabBarVC = [[MSTabBarController alloc] init];
    self.window.rootViewController = tabBarVC;
    [self.window makeKeyAndVisible];
}


#pragma mark - WXApiDelegate
- (void)onReq:(BaseReq *)req {
    QBLog(@"%@",req);
}

- (void)onResp:(BaseResp *)resp {
     if ([resp isKindOfClass:[PayResp class]]) {
        MSPayResult payResult;
        if (resp.errCode == WXErrCodeUserCancel) {
            payResult = MSPayResultCancle;
        } else if (resp.errCode == WXSuccess) {
            payResult = MSPayResultSuccess;
        } else {
            payResult = MSPayResultFailed;
        }
        [[WeChatPayManager sharedInstance] sendNotificationByResult:payResult];
    }
}


@end
