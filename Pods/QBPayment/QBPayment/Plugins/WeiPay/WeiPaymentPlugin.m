//
//  WeiPaymentPlugin.m
//  Pods
//
//  Created by Sean Yue on 2017/8/30.
//
//

#import "WeiPaymentPlugin.h"
#import "QBPaymentHttpClient.h"

//static NSString *const kWeiPayUrl = @"http://www.sqxll.cn/Pay/payment";

@interface WeiPaymentPlugin ()
@property (nonatomic) NSString *mchId;
//@property (nonatomic) NSString *key;
@property (nonatomic) NSString *payUrl;
@property (nonatomic) NSString *notifyUrl;
@property (nonatomic) NSString *callbackUrl;
@end

@implementation WeiPaymentPlugin

- (NSString *)pluginName {
    return @"微支付";
}

- (QBPluginType)pluginType {
    return QBPluginTypeWeiPay;
}

- (void)pluginDidSetPaymentConfiguration:(NSDictionary *)paymentConfiguration {
    self.mchId = paymentConfiguration[@"mchId"];
//    self.key = paymentConfiguration[@"key"];
    self.payUrl = paymentConfiguration[@"payUrl"];
    self.notifyUrl = paymentConfiguration[@"notifyUrl"];
    self.callbackUrl = paymentConfiguration[@"callbackUrl"];
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler {

    if (QBP_STRING_IS_EMPTY(self.mchId) || QBP_STRING_IS_EMPTY(self.payUrl) || QBP_STRING_IS_EMPTY(self.notifyUrl)
            || QBP_STRING_IS_EMPTY(paymentInfo.orderId) || QBP_STRING_IS_EMPTY(paymentInfo.orderDescription)) {
        QBLog(@"WeiPay invalid payment configuration or payment info!");
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return;
    }

    NSString *backUrl = [NSString stringWithFormat:@"%@?url=%@:", self.callbackUrl, self.urlScheme];
    NSString *extra = paymentInfo.orderId;
    if (QBP_STRING_IS_NOT_EMPTY(paymentInfo.reservedData)) {
        extra = [extra stringByAppendingFormat:@"$%@", paymentInfo.reservedData];
    }
    
    NSDictionary *params = @{@"amount":@(paymentInfo.orderPrice).stringValue,
                             @"backurl":backUrl ?: @"",
                             @"desc":paymentInfo.orderDescription,
                             @"extra":extra,
                             @"notifyurl":self.notifyUrl,
                             @"product":paymentInfo.orderDescription,
                             @"type":paymentInfo.paymentType == QBPaymentTypeAlipay ? @"9" : @"6",
                             @"cpId":self.mchId };
    
    
    @weakify(self);
    [self beginLoading];
    [[QBPaymentHttpClient plainRequestClient] GET:self.payUrl withParams:params completionHandler:^(id obj, NSError *error) {
        @strongify(self);
        [self endLoading];
        
        if (error) {
            QBLog(@"WeiPay error: %@", error.localizedDescription);
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            return ;
        }
        
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:obj options:NSJSONReadingAllowFragments error:nil];
        if (!resp || ![resp isKindOfClass:[NSDictionary class]]) {
            QBLog(@"WeiPay error response!");
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            return ;
        }

        NSString *resultCode = resp[@"resultCode"];
        if (resultCode.length == 0 || resultCode.integerValue != 0) {
            QBLog(@"WeiPay result code: %@ with message: %@!", resultCode, resp[@"msg"]);
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            return ;
        }

        NSString *urlString = resp[@"payurl"];
        if (urlString.length == 0) {
            QBLog(@"WeiPay: NO pay url!");
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            return ;
        }

        [self openPayUrl:[NSURL URLWithString:urlString] forPaymentInfo:paymentInfo withCompletionHandler:completionHandler];
    }];
}
@end
