//
//  HuiPaymentPlugin.m
//  Pods
//
//  Created by Sean Yue on 2017/7/25.
//
//

#import "HuiPaymentPlugin.h"
#import <QBPaymentHttpClient.h>
#import <NSString+md5.h>
#import <QBPaymentWebViewController.h>

static NSString *const kHuiPayUrl = @"http://api.chentianworld.com/waporder/order_add";

@interface HuiPaymentPlugin ()
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *notifyUrl;
@end

@implementation HuiPaymentPlugin

- (NSString *)pluginName {
    return @"惠付支付";
}

- (QBPluginType)pluginType {
    return QBPluginTypeHuiPay;
}

- (void)pluginDidSetPaymentConfiguration:(NSDictionary *)paymentConfiguration {
    self.mchId = paymentConfiguration[@"mch"];
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
                                    @"key":self.key,
                                    @"pay_type":paymentInfo.paymentType == QBPaymentTypeAlipay ? @"aliwap" : @"wxhtml",
                                    @"money":@(paymentInfo.orderPrice),
                                    @"time":@((long)[[NSDate date] timeIntervalSince1970]),
                                    @"order_id":paymentInfo.orderId,
                                    @"return_url":@"http://www.taobao.com",
                                    @"notify_url":self.notifyUrl ?: @"",
                                    @"extra":paymentInfo.reservedData ?: @""}.mutableCopy;
    
    NSArray *signingParams = @[@"order_id", @"money", @"pay_type", @"time", @"mch"];
    
    NSMutableString *signingString = [NSMutableString string];
    [signingParams enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [signingString appendFormat:@"%@", params[obj] ?: @""];
    }];
    [signingString appendString:self.key.md5];
    
    [params setObject:signingString.md5 forKey:@"sign"];
    
    NSMutableString *paramString = [NSMutableString string];
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (paramString.length > 0) {
            [paramString appendString:@"&"];
        }
        
        [paramString appendFormat:@"%@=%@", key, obj];
    }];
    
    @weakify(self);
    void (^CapturedPayment)(NSURL *url, id obj) = ^(NSURL *url, id obj) {
        @strongify(self);
        self.paymentInfo = paymentInfo;
        self.paymentCompletionHandler = completionHandler;
        self.payingViewController = obj;
//        ^(QBPayResult payResult, QBPaymentInfo *paymentInfo) {
//            [obj dismissViewControllerAnimated:YES completion:nil];
//            QBSafelyCallBlock(completionHandler, payResult, paymentInfo);
//        };
        
        [[UIApplication sharedApplication] openURL:url];
    };
    
    NSString *payUrl = [NSString stringWithFormat:@"%@?%@", kHuiPayUrl, paramString];
    QBPaymentWebViewController *webVC = [[QBPaymentWebViewController alloc] initWithURL:[NSURL URLWithString:payUrl]];
    webVC.capturedWeChatRequest = CapturedPayment;
    webVC.capturedAlipayRequest = CapturedPayment;
    webVC.capturedPaymentTimeOutAction = ^{
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
    };
    [[self viewControllerForPresentingPayment] presentViewController:webVC animated:YES completion:nil];
//    @weakify(self);
//    [[QBPaymentHttpClient plainRequestClient] GET:kPayUrl withParams:params completionHandler:^(id obj, NSError *error) {
//        @strongify(self);
//        
//        NSString *htmlText = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
//        QBLog(@"HuiPay response: %@", htmlText);
//        
//        QBPaymentWebViewController *webVC = [[QBPaymentWebViewController alloc] initWithHTMLString:htmlText];
//        webVC.shouldBeginLoadingWhenViewDidAppear = NO;
//        [[self viewControllerForPresentingPayment] presentViewController:webVC animated:YES completion:nil];
//        
//    }];
}

@end
