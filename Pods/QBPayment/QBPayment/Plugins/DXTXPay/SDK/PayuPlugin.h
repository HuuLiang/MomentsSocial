//
//  PayuPlugin.h
//  DXTXPaySDKDemo
//
//  Created by jmap on 16/9/7.
//  Copyright © 2016年 DXTXPaySDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  支付平台枚举
 */
typedef enum{
    PayTypeAliPay = 1,//支付宝
    PayTypeUnionpay = 3,//银联
    PayTypeWX = 2,//微信
    PayTypeWXPublicSignal = 4,//微信公众号
    PayTypeWXApp = 5,//微信APP
    PayTypeOther = 8,
    PayTypeCashier = 9
}PayType;

typedef void (^PayCompleteBlock)(NSDictionary *result);

@interface PayuPlugin : NSObject

/**
 *  SpaySDK 当前版本号
 *
 *  @return 版本号
 */
- (NSString*)spaySDKVersion;

/**
 *  创建支付单例服务
 *
 *  @return 返回单例对象
 */
+ (PayuPlugin *)defaultPlugin;

/**
 *  支付控件注册
 *
 *  @param appKey 支付品台获取的appKey
 *  @param appId Appid（应用编号）
 */
- (void)registWithAppKey:(NSString *)appKey appid:(NSString *) appid application:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions;



/**
 *  支付
 *
 *  @param pushFromCtrl  当前跳转的页面
 *  @param o_paymode_id  支付平台类型
 *  @param o_bizcode     商户订单号
 *  @param o_appid     Appid（应用编号）
 *  @param o_goods_name  商品名称（不传就已后台配置为准）
 *  @param o_price       商品价格
 *  @param o_address     通知地址（不传就已后台配置为准）
 *  @param o_showaddress H5同步通知地址（不传就已后台配置为准）
 *  @param o_privateinfo 商户私有信息,放置需要回传的信息(utf-8)
 *  @param appKey 支付品台获取的appKey
 */
- (void)payWithViewController:(UIViewController *)pushFromCtrl
                 o_paymode_id:(PayType)o_paymode_id
                    O_bizcode:(NSString *)o_bizcode
                      o_appid:(NSString *) o_appid
                 o_goods_name:(NSString *)o_goods_name
                      o_price:(double)o_price
                    o_address:(NSString *)o_address
                o_showaddress:(NSString *)o_showaddress
                o_privateinfo:(NSString *)o_privateinfo
                       Scheme:(NSString *)schemeStr
                       AppKey:(NSString *)appKey
                completeBlock:(PayCompleteBlock)completeBlock;


/**
 *  微信支付需要调用 iOS版微信Wap支付
 *
 *  @param application
 */
- (void)applicationWillEnterForeground:(UIApplication *)application;

/**
 *  微信支付需要调用 iOS版微信APP支付
 *
 *  @param application
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;

/**
 *  微信支付需要调用 iOS版微信APP支付9.0以前使用这个方法
 *
 *  @param application
 */
- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url;

/**
 *  微信支付需要调用 iOS版微信APP支付9.0以后使用这个方法
 *
 *  @param application
 */
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString*, id> *)options NS_AVAILABLE_IOS(9_0);

/**
 *  处理支付宝支付回调
 *
 *  @param url           回调地址
 */
- (void)processOrderWithPaymentResult:(NSURL *)url;


@end