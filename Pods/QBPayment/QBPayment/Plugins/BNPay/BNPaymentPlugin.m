//
//  BNPaymentPlugin.m
//  Pods
//
//  Created by Sean Yue on 2017/8/22.
//
//

#import "BNPaymentPlugin.h"
#import "QBPaymentHttpClient.h"
#import <NSString+md5.h>
#import "QBPaymentWebViewController.h"

static NSString *const kPayUrl = @"http://api.tellni.cn/waporder/order_add";
static NSString *const kQueryUrl = @"http://api.tellni.cn/lqpay/showquery";

@interface BNPaymentPlugin ()
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *notifyUrl;
@end

@implementation BNPaymentPlugin

- (NSString *)pluginName {
    return @"博诺支付";
}

- (QBPluginType)pluginType {
    return QBPluginTypeBNPay;
}

- (void)pluginDidSetPaymentConfiguration:(NSDictionary *)paymentConfiguration {
    self.mchId = paymentConfiguration[@"mchId"];
    self.key = paymentConfiguration[@"key"];
    self.notifyUrl = paymentConfiguration[@"notifyUrl"];
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo
         completionHandler:(QBPaymentCompletionHandler)completionHandler
{
    if (QBP_STRING_IS_EMPTY(self.mchId) || QBP_STRING_IS_EMPTY(self.key) || QBP_STRING_IS_EMPTY(paymentInfo.orderId)) {
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    NSMutableDictionary *params = @{@"mch":self.mchId,
                                    @"pay_type":[self BNPayTypeForPaymentType:paymentInfo.paymentType],
                                    @"money":@(paymentInfo.orderPrice),
                                    @"time":@((long)[[NSDate date] timeIntervalSince1970]),
                                    @"order_id":paymentInfo.orderId,
                                    @"return_url":@"http://www.taobao.com",
                                    @"notify_url":self.notifyUrl ?: @"",
                                    @"extra":paymentInfo.reservedData ?: @""}.mutableCopy;
    
    [params setObject:[self signWithParams:params withKeys:@[@"order_id",@"money",@"pay_type",@"time",@"mch"]]
               forKey:@"sign"];
    
    NSMutableString *str = [[NSMutableString alloc] init];
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (str.length > 0) {
            [str appendString:@"&"];
        }
        
        [str appendFormat:@"%@=%@", key, obj];
    }];
    
    NSString *url = [NSString stringWithFormat:@"%@?%@", kPayUrl, str];

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

- (NSString *)signWithParams:(NSDictionary *)params withKeys:(NSArray *)keys {
    NSMutableString *signingString = [[NSMutableString alloc] init];
    
//    NSArray *signingKeys = @[@"order_id",@"money",@"pay_type",@"time",@"mch"];
    [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *value = [NSString stringWithFormat:@"%@", params[obj]];
        [signingString appendString:value];
    }];
    
    [signingString appendString:self.key.md5.lowercaseString];
    
    NSString *sign = signingString.md5.lowercaseString;
    return sign;
}

- (NSString *)BNPayTypeForPaymentType:(QBPaymentType)payType {
    return payType == QBPaymentTypeAlipay ? @"aliwap":@"wxhtml";
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (self.paymentInfo) {
        
        if (QBP_STRING_IS_EMPTY(self.paymentInfo.orderId) || QBP_STRING_IS_EMPTY(self.mchId) || QBP_STRING_IS_EMPTY(self.key)) {
            [super applicationWillEnterForeground:application];
            return ;
        }
        
        NSMutableDictionary *params = @{@"order_id":self.paymentInfo.orderId,
                                        @"money":@(self.paymentInfo.orderPrice),
                                        @"mch":self.mchId,
                                        @"key":self.key,
                                        @"time":@((long)[[NSDate date] timeIntervalSince1970]),
                                        @"pay_type":[self BNPayTypeForPaymentType:self.paymentInfo.paymentType]}.mutableCopy;

        [params setObject:[self signWithParams:params withKeys:@[@"mch",@"order_id",@"money",@"pay_type",@"time"]] forKey:@"sign"];
        
        @weakify(self);
        [self beginLoading];
        [[QBPaymentHttpClient plainRequestClient] GET:kQueryUrl withParams:params completionHandler:^(id obj, NSError *error) {
            @strongify(self);
            [self endLoading];
            
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:obj options:NSJSONReadingAllowFragments error:nil];
            QBLog(@"BNPayment query response: %@", response);
            
            NSNumber *result = response[@"data"];
            QBPayResult payResult = result.unsignedIntegerValue == 1 ? QBPayResultSuccess : QBPayResultFailure;
            [self endPaymentWithPayResult:payResult];
        }];
    }
}
@end
