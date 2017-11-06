//
//  ZYPaymentPlugin.m
//  Pods
//
//  Created by Sean Yue on 2017/8/21.
//
//

#import "ZYPaymentPlugin.h"
#import "QBPaymentHttpClient.h"
#import <NSString+md5.h>

@interface ZYPaymentPlugin ()
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *payUrl;
@property (nonatomic) NSString *queryUrl;
@property (nonatomic) NSString *notifyUrl;
@property (nonatomic) NSString *callbackUrl;
@end

@implementation ZYPaymentPlugin

- (NSString *)pluginName {
    return @"卓越支付";
}

- (QBPluginType)pluginType {
    return QBPluginTypeZYPay;
}

- (void)pluginDidSetPaymentConfiguration:(NSDictionary *)paymentConfiguration {
    self.mchId = paymentConfiguration[@"mchNo"];
    self.key = paymentConfiguration[@"key"];
    self.payUrl = paymentConfiguration[@"payUrl"];
    self.queryUrl = paymentConfiguration[@"queryUrl"];
    self.notifyUrl = paymentConfiguration[@"notifyUrl"];
    self.callbackUrl = paymentConfiguration[@"callbackUrl"];
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo
         completionHandler:(QBPaymentCompletionHandler)completionHandler
{
    if (QBP_STRING_IS_EMPTY(self.payUrl)
        || QBP_STRING_IS_EMPTY(self.mchId)
        || QBP_STRING_IS_EMPTY(self.key)
        || QBP_STRING_IS_EMPTY(self.notifyUrl)
        || QBP_STRING_IS_EMPTY(paymentInfo.orderId)) {
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    BOOL orderDescIsChinese = [self isChineseString:paymentInfo.orderDescription];
    NSAssert(!orderDescIsChinese, @"Order Description CANNOT contain Chinese!");
    
    if (orderDescIsChinese) {
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    NSString *callbackUrl = [NSString stringWithFormat:@"%@?url=%@:", self.callbackUrl, self.urlScheme];
    
    NSMutableDictionary *params = @{@"mer_id":self.mchId,
                                    @"out_trade_no":paymentInfo.orderId,
                                    @"pay_type":paymentInfo.paymentType == QBPaymentTypeAlipay ? @"006" : @"001",
                                    @"goods_name":paymentInfo.orderDescription,
                                    @"total_fee":@(paymentInfo.orderPrice),
                                    @"callback_url":callbackUrl,
                                    @"notify_url":self.notifyUrl ?: @"",
                                    @"attach":paymentInfo.reservedData ?: @"",
                                    @"nonce_str":self.uniqueString}.mutableCopy;
    
    NSArray *signingKeys = @[@"mer_id",@"out_trade_no",@"total_fee",@"nonce_str"];
    signingKeys = [signingKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableString *signString = [[NSMutableString alloc] init];
    [signingKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *value = [NSString stringWithFormat:@"%@", params[obj] ?: @""];
        if (value.length > 0) {
//            if (signString.length > 0) {
//                [signString appendString:@"&"];
//            }
            
            [signString appendFormat:@"%@=%@&", obj, value];
        }
    }];
    
    [signString appendFormat:@"key=%@", self.key];
    
    NSString *sign = signString.md5.lowercaseString;
    [params setObject:sign forKey:@"sign"];
    
    @weakify(self);
    [self beginLoading];
    [[QBPaymentHttpClient plainRequestClient] GET:self.payUrl withParams:params completionHandler:^(id obj, NSError *error) {
        @strongify(self);
        [self endLoading];
        if (error) {
            QBLog(@"ZYPay error: %@", error.localizedDescription);
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            return ;
        }
        
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:obj options:NSJSONReadingAllowFragments error:nil];
        QBLog(@"ZYPayment Response: %@", response);
        
        NSString *code_url = response[@"code_url"];
        if (code_url.length == 0) {
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            return ;
        }
        
        self.paymentInfo = paymentInfo;
        self.paymentCompletionHandler = completionHandler;
        
        if (paymentInfo.paymentType == QBPaymentTypeAlipay) {
            [self openPayUrl:[NSURL URLWithString:code_url] forPaymentInfo:paymentInfo withCompletionHandler:completionHandler];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:code_url]];
        }
        
    }];
}

- (BOOL)isChineseString:(NSString *)string
{
    for (int i=0; i<string.length; i++) {
        
        NSRange range =NSMakeRange(i, 1);
        
        NSString * strFromSubStr=[string substringWithRange:range];
        
        const char *cStringFromstr = [strFromSubStr UTF8String];
        
        if (strlen(cStringFromstr) > 1) {
            return YES;
        }
        
    }
    
    return NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (self.paymentInfo) {
        if (QBP_STRING_IS_EMPTY(self.paymentInfo.orderId) || QBP_STRING_IS_EMPTY(self.queryUrl)) {
            [super applicationWillEnterForeground:application];
            return ;
        }
        
        @weakify(self);
        [[QBPaymentHttpClient plainRequestClient] GET:self.queryUrl
                                           withParams:@{@"out_trade_no":self.paymentInfo.orderId}
                                    completionHandler:^(id obj, NSError *error)
        {
            @strongify(self);

            NSString *response = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
            QBLog(@"BNPayment query response: %@", response);
            
            if ([response isEqualToString:@"success"]) {
                [self endPaymentWithPayResult:QBPayResultSuccess];
            } else {
                [super applicationWillEnterForeground:application];
            }
            
        }];
    }
}
@end
