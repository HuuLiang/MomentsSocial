//
//  BBPaymentPlugin.m
//  Pods
//
//  Created by Sean Yue on 2017/9/18.
//
//

#import "BBPaymentPlugin.h"
#import <NSString+md5.h>
#import "QBPaymentWebViewController.h"
#import "QBPaymentHttpClient.h"

static NSString *const kBBPayUrl = @"http://pay.zhangzhongzhifu.com/sdkServer/thirdpays/pay/";
static NSString *const kBBQueryUrl = @"http://pay.zhangzhongzhifu.com/sdkServer/thirdpayorder";

@interface BBPaymentPlugin ()
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *notifyUrl;
@property (nonatomic) NSString *payingOrderId;
@end

@implementation BBPaymentPlugin

- (QBPluginType)pluginType {
    return QBPluginTypeBBPay;
}

- (NSString *)pluginName {
    return @"贝贝支付";
}

- (NSUInteger)minimalPrice {
    return 100;
}

- (void)pluginDidSetPaymentConfiguration:(NSDictionary *)paymentConfiguration {
    self.mchId = paymentConfiguration[@"mchId"];
    self.key = paymentConfiguration[@"key"];
    self.notifyUrl = paymentConfiguration[@"notifyUrl"];
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler {
    if (QBP_STRING_IS_EMPTY(self.mchId) || QBP_STRING_IS_EMPTY(self.key) || QBP_STRING_IS_EMPTY(self.notifyUrl)) {
        QBLog(@"Invalid payment configuration: %@", self.paymentConfiguration);
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    if (paymentInfo.orderPrice == 0 || QBP_STRING_IS_EMPTY(paymentInfo.orderId) || (paymentInfo.paymentType != QBPaymentTypeWeChat && paymentInfo.paymentType != QBPaymentTypeAlipay)) {
        QBLog(@"Invalid payment info: %@", paymentInfo.description);
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    NSString *transp = paymentInfo.orderId;
    if (QBP_STRING_IS_NOT_EMPTY(paymentInfo.reservedData)) {
        transp = [NSString stringWithFormat:@"%@$%@", transp, paymentInfo.reservedData];
    }
    
    NSString *service = paymentInfo.paymentType == QBPaymentTypeAlipay ? @"ALIPAY_WAP" : @"WECHAT_WAP";
    NSMutableDictionary *params = @{@"appid":self.mchId,
                                    @"money":@(paymentInfo.orderPrice),
                                    @"productName":paymentInfo.orderDescription,
                                    @"transp":transp,
                                    @"api":@0}.mutableCopy;
    
    NSArray *signingKeys = @[@"appid", @"service", @"money", @"transp"];
    NSMutableString *signingString = [NSMutableString string];
    [signingKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *value;
        if ([obj isEqualToString:@"service"]) {
            value = service;
        } else {
            value = [NSString stringWithFormat:@"%@", params[obj] ?: @""];
        }
        
        if (QBP_STRING_IS_NOT_EMPTY(value)) {
            [signingString appendString:value];
        }
    }];

    [signingString appendString:self.key];
    
    NSString *sign = signingString.md5;
//    [params setObject:sign forKey:@"sign"];
    
    NSMutableString *url = [NSMutableString string];
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        if (QBP_STRING_IS_NOT_EMPTY(url)) {
            [url appendString:@"&"];
        }
        
        NSString *entry = [NSString stringWithFormat:@"%@=%@", key, obj];
        [url appendString:entry];
    }];
    
    [url appendFormat:@"&sign=%@", sign];
    
    NSString *urlString = [[NSString stringWithFormat:@"%@%@?%@", kBBPayUrl, service, url] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    QBLog(@"BB payment url: %@", urlString);
    
    @weakify(self);
    void (^capturedRequest)(NSURL *url, id obj) = ^(NSURL *url, id obj) {
        @strongify(self);
        
        self.payingOrderId = transp;
        self.paymentInfo = paymentInfo;
        self.paymentCompletionHandler = completionHandler;
        self.payingViewController = obj;
        
        [[UIApplication sharedApplication] openURL:url];
    };
    
    QBPaymentWebViewController *webVC = [[QBPaymentWebViewController alloc] initWithURL:[NSURL URLWithString:urlString]];
    webVC.capturedWeChatRequest = capturedRequest;
    webVC.capturedAlipayRequest = capturedRequest;
    [[self viewControllerForPresentingPayment] presentViewController:webVC animated:YES completion:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (self.paymentInfo) {
        if (QBP_STRING_IS_EMPTY(self.payingOrderId) || QBP_STRING_IS_EMPTY(self.mchId) || QBP_STRING_IS_EMPTY(self.key)) {
            [super applicationWillEnterForeground:application];
            return ;
        }
        
        NSString *sign = [NSString stringWithFormat:@"%@%@%@", self.mchId, self.payingOrderId, self.key].md5;
        NSString *url = [NSString stringWithFormat:@"%@?appid=%@&orderid=%@&sign=%@", kBBQueryUrl, self.mchId, self.payingOrderId, sign];
        QBLog(@"BBPay query url: %@", url);
        
        @weakify(self);
//        [self beginLoading];
        [[QBPaymentHttpClient plainRequestClient] GET:url withParams:nil completionHandler:^(id obj, NSError *error) {
            @strongify(self);
//            [self endLoading];
            
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:obj options:NSJSONReadingAllowFragments error:nil];
            QBLog(@"BNPayment query response: %@", response);
            
            NSNumber *code = response[@"errcode"];
            if (!code || code.integerValue != 0) {
                [super applicationWillEnterForeground:application];
                return ;
            }
            NSDictionary *result = response[@"result"];
            NSNumber *status = result[@"status"];
            QBPayResult payResult = status.integerValue == 3 ? QBPayResultSuccess : QBPayResultFailure;
            
            if (payResult == QBPayResultFailure) {
                [super applicationWillEnterForeground:application];
            } else {
                [self endPaymentWithPayResult:payResult];
            }
        }];
    }
}
@end
