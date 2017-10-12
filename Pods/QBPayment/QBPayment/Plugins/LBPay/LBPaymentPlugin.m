//
//  LBPaymentPlugin.m
//  QBPayment
//
//  Created by Sean Yue on 2017/9/28.
//

#import "LBPaymentPlugin.h"
#import <NSString+md5.h>
#import "QBPaymentWebViewController.h"
#import "QBPaymentHttpClient.h"

static NSString *const kLBPayUrl = @"http://www.luobopay.com/apisubmit";
static NSString *const kLBQueryUrl = @"http://www.luobopay.com/apiorderquery";

@interface LBPaymentPlugin ()
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *notifyUrl;
@end

@implementation LBPaymentPlugin

- (NSString *)pluginName {
    return @"萝卜云支付";
}

- (QBPluginType)pluginType {
    return QBPluginTypeLBPay;
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
    
    if (QBP_STRING_IS_EMPTY(self.key) || QBP_STRING_IS_EMPTY(self.mchId) || QBP_STRING_IS_EMPTY(self.notifyUrl) || QBP_STRING_IS_EMPTY(paymentInfo.orderId)) {
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    NSMutableDictionary *params = @{@"version":@"1.0",
                                    @"customerid":@(self.mchId.integerValue),
                                    @"sdorderno":paymentInfo.orderId,
                                    @"total_fee":[NSString stringWithFormat:@"%.2f", paymentInfo.orderPrice / 100.],
                                    @"paytype":paymentInfo.paymentType == QBPaymentTypeAlipay ? @"alipaywap":@"wxh5",
                                    @"notifyurl":self.notifyUrl,
                                    @"returnurl":[NSString stringWithFormat:@"%@://", self.urlScheme],
                                    @"remark":paymentInfo.reservedData ?: @""
                                    }.mutableCopy;
    
    NSArray *signingKeys = @[@"version",@"customerid",@"total_fee",@"sdorderno",@"notifyurl",@"returnurl"];
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
    [signingString appendFormat:@"&%@", self.key];
    
    NSMutableString *urlQuery = [NSMutableString string];
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *value = [NSString stringWithFormat:@"%@", obj ?: @""];
        if (QBP_STRING_IS_NOT_EMPTY(value)) {
            if (QBP_STRING_IS_NOT_EMPTY(urlQuery)) {
                [urlQuery appendString:@"&"];
            }
            [urlQuery appendFormat:@"%@=%@", key, value];
        }
    }];
    [urlQuery appendFormat:@"&sign=%@", signingString.md5];
    
    NSString *url = [NSString stringWithFormat:@"%@?%@", kLBPayUrl, urlQuery];
    QBLog(@"LePay url: %@", url);
    
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

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (self.paymentInfo) {
        if (QBP_STRING_IS_EMPTY(self.paymentInfo.orderId) || QBP_STRING_IS_EMPTY(self.mchId) || QBP_STRING_IS_EMPTY(self.key)) {
            [super applicationWillEnterForeground:application];
            return ;
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyymmddhhmmss"];
        
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        
        NSString *sign = [NSString stringWithFormat:@"customerid=%@&sdorderno=%@&reqtime=%@&%@", self.mchId, self.paymentInfo.orderId, dateString, self.key].md5;
        NSDictionary *params = @{@"customerid":@(self.mchId.integerValue),
                                 @"sdorderno":self.paymentInfo.orderId,
                                 @"reqtime":dateString,
                                 @"sign":sign};
        
        
        
        @weakify(self);
        [[QBPaymentHttpClient plainRequestClient] POST:kLBQueryUrl withParams:params completionHandler:^(id obj, NSError *error) {
            @strongify(self);
            
            NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:obj options:NSJSONReadingAllowFragments error:nil];
            
            NSNumber *status = resp[@"status"];
            if (status.integerValue == 1) {
                [self endPaymentWithPayResult:QBPayResultSuccess];
            } else {
                [super applicationWillEnterForeground:application];
            }
        }];
    }
}

@end
