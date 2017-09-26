//
//  MSPaymentManager.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MSPayInfo;

typedef void(^PayResult)(BOOL success);

@interface MSPaymentManager : NSObject

+ (instancetype)manager;

- (void)setup;

- (void)handleOpenURL:(NSURL *)url;

- (void)applicationWillEnterForeground:(UIApplication *)application;

- (void)startPayForVipLevel:(MSLevel)vipLevel type:(MSPayType)payType price:(NSInteger)price contentType:(MSPopupType)contentType payPoints:(NSArray <MSPayInfo *> *)payPoints handler:(PayResult)handler;

//- (void)startPayForVipLevel:(MSLevel)vipLevel type:(MSPayType)payType price:(NSInteger)price contentType:(MSPopupType)contentType handler:(PayResult)handler;

- (void)commitPayResult:(MSPayResult)payResult handler:(PayResult)hander;

- (BOOL)weixinPayEnable;

- (BOOL)aliPayEnable;

- (BOOL)checkIsPaidGoldVip;

@end
