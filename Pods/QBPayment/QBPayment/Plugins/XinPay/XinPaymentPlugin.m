//
//  XinPaymentPlugin.m
//  Pods
//
//  Created by Sean Yue on 2017/8/22.
//
//

#import "XinPaymentPlugin.h"
#import "QBPaymentHttpClient.h"
#import "QBPaymentWebViewController.h"
#import <NSString+md5.h>

static NSString *const kXinPayUrl = @"http://pay.api.flypush.com/api/wypay/createOrder";
static NSString *const kXinQueryUrl = @"http://pay.api.flypush.com/api/bill/status";

@interface XinPaymentPlugin ()
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *notifyUrl;

@property (nonatomic) NSString *prePayOrderId;
@end

@implementation XinPaymentPlugin

- (NSString *)pluginName {
    return @"鑫支付";
}
    
- (QBPluginType)pluginType {
    return QBPluginTypeXinPay;
}

- (void)pluginDidSetPaymentConfiguration:(NSDictionary *)paymentConfiguration {
    self.mchId = paymentConfiguration[@"mchId"];
    self.key = paymentConfiguration[@"key"];
    self.notifyUrl = paymentConfiguration[@"notifyUrl"];
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler {
    
    if (QBP_STRING_IS_EMPTY(self.mchId) || QBP_STRING_IS_EMPTY(self.key) || QBP_STRING_IS_EMPTY(paymentInfo.orderDescription)) {
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    NSString *reservedData = [NSString stringWithFormat:@"%@$%@", paymentInfo.orderId, paymentInfo.reservedData];
    
    NSMutableDictionary *params = @{@"mchno":self.mchId,
                                    @"pay_type":@3,
                                    @"price":@(paymentInfo.orderPrice),
                                    @"bill_title":paymentInfo.orderDescription,
                                    @"bill_body":paymentInfo.orderDescription,
                                    @"nonce_str":[NSUUID UUID].UUIDString.md5,
                                    @"callback_url":@"www.taobao.com",
                                    @"linkId":reservedData ?: @""}.mutableCopy;
    
    NSMutableString *signingString = [[NSMutableString alloc] init];
    NSArray *signingKeys = [params.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    [signingKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *value = [NSString stringWithFormat:@"%@", params[obj] ?: @""];
        if (value.length > 0) {
            [signingString appendFormat:@"%@=%@&", obj, value];
        }
    }];
    
    [signingString appendFormat:@"key=%@", self.key];
    
    NSString *sign = signingString.md5.uppercaseString;
    [params setObject:sign forKey:@"sign"];
    
    @weakify(self);
    [self beginLoading];
    [[QBPaymentHttpClient JSONRequestClient] POST:kXinPayUrl withParams:params completionHandler:^(id obj, NSError *error) {
        @strongify(self);
        [self endLoading];
        
        if (error) {
            QBLog(@"XinPayment error: %@", error.localizedDescription);
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            return ;
        }
        
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:obj options:NSJSONReadingAllowFragments error:nil];
        QBLog(@"XinPayment response: %@", response);
        
        NSNumber *resultCode = response[@"resultCode"];
        if (resultCode.unsignedIntegerValue != 200) {
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            return ;
        }
        
        NSDictionary *order = response[@"order"];
        NSString *payUrl = order[@"pay_link"];
        if (QBP_STRING_IS_EMPTY(payUrl)) {
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            return ;
        }
        
        QBPaymentWebViewController *webVC = [[QBPaymentWebViewController alloc] initWithURL:[NSURL URLWithString:payUrl]];
        webVC.capturedWeChatRequest = ^(NSURL *url, id obj) {
            @strongify(self);
            self.paymentCompletionHandler = completionHandler;
            self.paymentInfo = paymentInfo;
            self.prePayOrderId = order[@"bill_no"];
            
            [[UIApplication sharedApplication] openURL:url];
        };
        self.payingViewController = webVC;
        [[self viewControllerForPresentingPayment] presentViewController:webVC animated:YES completion:nil];
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (self.paymentInfo) {
        @weakify(self);
        
        [[QBPaymentHttpClient plainRequestClient] GET:kXinQueryUrl withParams:@{@"billno":self.prePayOrderId ?: @""} completionHandler:^(id obj, NSError *error) {
            @strongify(self);
            
            QBPayResult payResult = QBPayResultFailure;
            
            if (obj) {
                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:obj options:NSJSONReadingAllowFragments error:nil];
                QBLog(@"XinPayment query response: %@", response);
                
                NSNumber *resultCode = response[@"resultCode"];
                NSNumber *status = response[@"bill_status"];
                if (resultCode.unsignedIntegerValue == 200 && status.unsignedIntegerValue == 2) {
                    payResult = QBPayResultSuccess;
                }
            }
            
            [self endPaymentWithPayResult:payResult];
        }];
    }
}
@end
