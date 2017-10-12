//
//  RocketPaymentPlugin.m
//  QBPayment
//
//  Created by Sean Yue on 2017/10/12.
//

#import "RocketPaymentPlugin.h"
#import <NSString+md5.h>
#import "QBPaymentHttpClient.h"
#import "QBPaymentWebViewController.h"

static NSString *const kRocketPayUrl = @"http://weinxin.pxblh.cn/platform/pay/gateway/video/";

@interface RocketPaymentPlugin ()
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *notifyUrl;
@property (nonatomic) NSString *callbackUrl;
@end

@implementation RocketPaymentPlugin

- (NSString *)pluginName {
    return @"火箭支付";
}

- (QBPluginType)pluginType {
    return QBPluginTypeRocketPay;
}

- (void)pluginDidSetPaymentConfiguration:(NSDictionary *)paymentConfiguration {
    self.mchId = paymentConfiguration[@"mchId"];
    self.key = paymentConfiguration[@"key"];
    self.notifyUrl = paymentConfiguration[@"notifyUrl"];
    self.callbackUrl = paymentConfiguration[@"callbackUrl"];
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler {
    if (QBP_STRING_IS_EMPTY(self.mchId) || QBP_STRING_IS_EMPTY(self.key) || QBP_STRING_IS_EMPTY(self.notifyUrl)) {
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    NSString *orderId = paymentInfo.orderId;
    if (QBP_STRING_IS_NOT_EMPTY(paymentInfo.reservedData)) {
        orderId = [NSString stringWithFormat:@"%@$%@", orderId, paymentInfo.reservedData];
    }
    
    NSString *callbackUrl = [NSString stringWithFormat:@"%@?url=%@:", self.callbackUrl, self.urlScheme];
    
    NSMutableDictionary *params = @{@"mch_id":self.mchId,
                                    @"out_trade_no":orderId,
                                    @"subject":paymentInfo.orderDescription,
                                    @"total_fee":@(paymentInfo.orderPrice),
                                    @"terminal_ip":self.IPAddress,
                                    @"notify_url":self.notifyUrl,
                                    @"callback_url":callbackUrl,
                                    @"pay_way":paymentInfo.paymentType == QBPaymentTypeAlipay ? @"ALI" : @"WX"
                                    }.mutableCopy;
    
    NSArray *signingKeys = [params.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableString *signingString = [NSMutableString string];
    [signingKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *value = [NSString stringWithFormat:@"%@", params[obj] ?: @""];
        if (QBP_STRING_IS_NOT_EMPTY(value)) {
            if (QBP_STRING_IS_NOT_EMPTY(signingString)) {
                [signingString appendString:@"&"];
            }
            [signingString appendFormat:@"%@=%@", obj, value];
        }
    }];
    
    NSString *query = signingString.mutableCopy;
    
    [signingString appendFormat:@"&key=%@", self.key];
    NSString *sign = signingString.md5.lowercaseString;
    
    query = [query stringByAppendingFormat:@"&sign=%@", sign];
    
    NSString *url = [[NSString stringWithFormat:@"%@?%@", kRocketPayUrl, query] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    @weakify(self);
    void (^capturedRequest)(NSURL *url, id obj) = ^(NSURL *url, id obj) {
        @strongify(self);
        
        self.paymentInfo = paymentInfo;
        self.paymentCompletionHandler = completionHandler;
        self.payingViewController = obj;
        
        [[UIApplication sharedApplication] openURL:url];
    };
    
    QBPaymentWebViewController *webVC = [[QBPaymentWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
    webVC.capturedWeChatRequest = capturedRequest;
    webVC.capturedAlipayRequest = capturedRequest;
    [[self viewControllerForPresentingPayment] presentViewController:webVC animated:YES completion:nil];
}
@end
