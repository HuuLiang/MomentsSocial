//
//  QBPaymentManager.h
//  Pods
//
//  Created by Sean Yue on 2017/6/1.
//
//

#import <Foundation/Foundation.h>
#import "QBPaymentDefines.h"
#import "QBOrderInfo.h"
#import "QBContentInfo.h"
#import "QBPayPoint.h"

@interface QBPaymentManager : NSObject

+ (instancetype _Nonnull)sharedManager;

- (void)registerPaymentWithSettings:(NSDictionary *_Nonnull)settings;

- (void)payWithOrderInfo:(QBOrderInfo *_Nonnull)orderInfo
             contentInfo:(QBContentInfo *_Nullable)contentInfo
       completionHandler:(QBPaymentCompletionHandler _Nonnull )completionHandler;

- (void)payWithOrderInfo:(QBOrderInfo *_Nonnull)orderInfo
             contentInfo:(QBContentInfo *_Nullable)contentInfo
                payPoint:(QBPayPoint *_Nullable)payPoint
       completionHandler:(QBPaymentCompletionHandler _Nonnull )completionHandler;

- (void)activatePaymentInfos:(NSArray<QBPaymentInfo *> *_Nonnull)paymentInfos
       withCompletionHandler:(QBCompletionHandler _Nullable )completionHandler;

- (void)refreshPaymentConfigurationWithCompletionHandler:(QBCompletionHandler _Nullable )completionHandler;

@end

@interface QBPaymentManager (PluginQueries)

- (BOOL)pluginIsEnabled:(QBPluginType)pluginType;
- (QBPluginType)pluginTypeForPaymentType:(QBPaymentType)paymentType;
- (NSUInteger)minialPriceForPaymentType:(QBPaymentType)paymentType;

- (NSArray<NSNumber *> *_Nullable)availablePaymentTypes;
- (NSUInteger)discountOfPaymentType:(QBPaymentType)paymentType;  // discount is represented by percent, e.g. 90 means 90% discount

@end

@interface QBPaymentManager (PayPoints)

@property (nonatomic,retain,readonly) QBPayPoints * _Nullable payPoints;

- (void)fetchPayPointsWithCompletionHandler:(QBCompletionHandler _Nullable)completionHandler;

@end

@interface QBPaymentManager (ApplicationCallback)

- (void)applicationWillEnterForeground:(UIApplication *_Nonnull)application;
- (void)handleOpenUrl:(NSURL *_Nonnull)url;

@end

// Keys of payment options
FOUNDATION_EXTERN NSString * _Nonnull const kQBPaymentSettingChannelNo;
FOUNDATION_EXTERN NSString * _Nonnull const kQBPaymentSettingAppId;
FOUNDATION_EXTERN NSString * _Nonnull const kQBPaymentSettingPv;
FOUNDATION_EXPORT NSString * _Nonnull const kQBPaymentSettingPayPointVersion;

// 支付app回调的url scheme
FOUNDATION_EXTERN NSString * _Nonnull const kQBPaymentSettingUrlScheme;

// 默认的超时时间，单位秒
FOUNDATION_EXTERN NSString * _Nonnull const kQBPaymentSettingDefaultTimeount;

// 指定默认的支付配置信息, value可以是QBPaymentConfiguration或者NSDictionary或者NSString(plist文件名，不包含扩展名)的实例
FOUNDATION_EXTERN NSString * _Nonnull const kQBPaymentSettingDefaultConfig;

// 是否使用测试环境的支付配置信息， value为BOOL类型
FOUNDATION_EXTERN NSString * _Nonnull const kQBPaymentSettingUseConfigInTestServer;

// Notifications
FOUNDATION_EXTERN NSString * _Nonnull const kQBPaymentWillBeginPaymentNotification;
FOUNDATION_EXTERN NSString * _Nonnull const kQBPaymentDidFetchPaymentConfigNotification;
