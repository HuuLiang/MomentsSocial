//
//  DXTXPaymentPlugin.m
//  Pods
//
//  Created by Sean Yue on 2017/7/31.
//
//

#import "DXTXPaymentPlugin.h"
#import "PayuPlugin.h"

@interface DXTXPaymentPlugin ()
@property (nonatomic) NSString *appKey;
@property (nonatomic) NSString *appSign;
@property (nonatomic) NSString *appid;
@property (nonatomic) NSString *notifyUrl;
//@property (nonatomic) NSNumber *waresid;
@end

@implementation DXTXPaymentPlugin

- (QBPluginType)pluginType {
    return QBPluginTypeDXTXPay;
}

- (NSString *)pluginName {
    return @"盾行天下";
}

- (void)pluginDidSetPaymentConfiguration:(NSDictionary *)paymentConfiguration {
    self.appKey = paymentConfiguration[@"appKey"];
    self.appSign = paymentConfiguration[@"appSign"];
    self.appid = paymentConfiguration[@"appid"];
    self.notifyUrl = paymentConfiguration[@"notifyUrl"];
//    self.waresid = paymentConfiguration[@"waresid"];
    
    [[PayuPlugin defaultPlugin] registWithAppKey:self.appKey appid:self.appid application:[UIApplication sharedApplication] launchOptions:nil];
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo
         completionHandler:(QBPaymentCompletionHandler)completionHandler
{
    if (QBP_STRING_IS_EMPTY(self.appKey) || QBP_STRING_IS_EMPTY(self.appSign) || QBP_STRING_IS_EMPTY(self.appid)
        || QBP_STRING_IS_EMPTY(self.notifyUrl) || QBP_STRING_IS_EMPTY(paymentInfo.orderId) || QBP_STRING_IS_EMPTY(paymentInfo.orderDescription)) {
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    [[PayuPlugin defaultPlugin] payWithViewController:self.viewControllerForPresentingPayment
                                         o_paymode_id:paymentInfo.paymentType == QBPaymentTypeAlipay ? PayTypeAliPay : PayTypeWX
                                            O_bizcode:paymentInfo.orderId
                                              o_appid:self.appid
                                         o_goods_name:paymentInfo.orderDescription
                                              o_price:paymentInfo.orderPrice/100.
                                            o_address:self.notifyUrl
                                        o_showaddress:@"www.taobao.com"
                                        o_privateinfo:paymentInfo.reservedData
                                               Scheme:self.urlScheme
                                               AppKey:self.appKey
                                        completeBlock:^(NSDictionary *result)
    {
        QBLog(@"DXTX payment response: %@", result);
        
        NSInteger code = [result[@"resultStatus"] integerValue];
        QBPayResult payResult = QBPayResultFailure;
        if (code == 6001) {
            payResult = QBPayResultCancelled;
        } else if (code == 9000) {
            payResult = QBPayResultSuccess;
        }

        [[self class] commitPayment:paymentInfo withResult:payResult];
        QBSafelyCallBlock(completionHandler, payResult, paymentInfo);
    }];
}

- (void)handleOpenURL:(NSURL *)url {
    [[PayuPlugin defaultPlugin] application:[UIApplication sharedApplication] handleOpenURL:url];
    [[PayuPlugin defaultPlugin] processOrderWithPaymentResult:url];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[PayuPlugin defaultPlugin] applicationWillEnterForeground:application];
}
@end
