//
//  WeChatPaymentPlugin.m
//  Pods
//
//  Created by Sean Yue on 2017/6/28.
//
//

#import "WeChatPaymentPlugin.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "QBPaymentHttpClient.h"
#import <NSString+md5.h>
#import <XMLDictionary.h>
#import <MBProgressHUD.h>

static NSString *const kPrePayUrl = @"https://api.mch.weixin.qq.com/pay/unifiedorder";
static NSString *const kOrderQueryUrl = @"https://api.mch.weixin.qq.com/pay/orderquery";

@interface WeChatPaymentPlugin () <WXApiDelegate>

@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *signKey;
@property (nonatomic) NSString *notifyUrl;

@end

@implementation WeChatPaymentPlugin

- (QBPluginType)pluginType {
    return QBPluginTypeWeChatPay;
}

- (NSString *)pluginName {
    return @"微信支付";
}

- (void)pluginDidLoad {
    
}

- (void)setPaymentConfiguration:(NSDictionary *)paymentConfiguration {
    [super setPaymentConfiguration:paymentConfiguration];
    
    self.appId = paymentConfiguration[@"appId"];
    self.mchId = paymentConfiguration[@"mchId"];
    self.signKey = paymentConfiguration[@"signKey"];
    self.notifyUrl = paymentConfiguration[@"notifyUrl"];
    
//    [WXApi registerApp:self.appId];
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler {
    if (QBP_STRING_IS_EMPTY(self.appId) || QBP_STRING_IS_EMPTY(self.mchId) || QBP_STRING_IS_EMPTY(self.signKey) || QBP_STRING_IS_EMPTY(self.notifyUrl) || QBP_STRING_IS_EMPTY(paymentInfo.orderId) || QBP_STRING_IS_EMPTY(paymentInfo.orderDescription)) {
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    srand( (unsigned)time(0) );
    NSString *nonce_str  = [NSString stringWithFormat:@"%d", rand()];
    
    NSMutableDictionary *params = @{@"appid":self.appId,
                                    @"mch_id":self.mchId,
                                    @"nonce_str":nonce_str,
                                    @"body":paymentInfo.orderDescription,
                                    @"attach":paymentInfo.reservedData ?: @"",
                                    @"out_trade_no":paymentInfo.orderId,
                                    @"total_fee":@(paymentInfo.orderPrice).stringValue,
                                    @"spbill_create_ip":self.IPAddress ?: @"",
                                    @"notify_url":self.notifyUrl,
                                    @"trade_type":@"APP"}.mutableCopy;
    
    [params setObject:[self sign:params] forKey:@"sign"];
    
    @weakify(self);
    NSDictionary *xmlParams = @{@"xml":params};
    NSString *xmlString = xmlParams.XMLString;
    
    [self beginLoading];
    [[QBPaymentHttpClient sharedClient] POST:kPrePayUrl withXMLText:xmlString completionHandler:^(id obj, NSError *error) {
        @strongify(self);
        [self endLoading];
        
        NSDictionary *response = [NSDictionary dictionaryWithXMLData:obj];
        
        if (![response[@"return_code"] isEqualToString:@"SUCCESS"]
            || ![response[@"result_code"] isEqualToString:@"SUCCESS"]
            || !response[@"prepay_id"]) {
            QBLog(@"‼️WeChatPay PrePay fails:\n%@‼️", response[@"return_msg"]);
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            return ;
        }
        
        time_t now;
        time(&now);
        NSString *timeStamp = [NSString stringWithFormat:@"%ld", now];
        NSString *nonce_str = timeStamp.md5;
        
        NSDictionary *signDic = @{@"appid":self.appId,
                                  @"noncestr":nonce_str,
                                  @"package":@"Sign=WXPay",
                                  @"partnerid":self.mchId,
                                  @"timestamp":timeStamp,
                                  @"prepayid":response[@"prepay_id"]};
        
        PayReq *payReq = [[PayReq alloc] init];
        payReq.openID = self.appId;
        payReq.partnerId = self.mchId;
        payReq.prepayId = signDic[@"prepayid"];
        payReq.nonceStr = signDic[@"noncestr"];
        payReq.timeStamp = (UInt32)now;
        payReq.sign = [self sign:signDic];
        payReq.package = @"Sign=WXPay";
        
        [WXApi registerApp:self.appId];
        BOOL success = [WXApi sendReq:payReq];
        if (!success) {
            QBLog(@"‼️WeChatPay fails to invoke payment‼️")
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        } else {
            QBLog(@"✅WeChatPay succeeds to invoke payment✅")
            self.paymentInfo = paymentInfo;
            self.paymentCompletionHandler = completionHandler;
        }
    }];
}

- (NSString *)sign:(NSDictionary *)dic {
    NSArray *sortedKeys = [dic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    NSMutableString *signedString = [NSMutableString string];
    [sortedKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isEqualToString:@"sign"] || [obj isEqualToString:@"key"]) {
            return ;
        }
        
        NSString *value = dic[obj];
        
        if (value.length > 0) {
            if (signedString.length > 0) {
                [signedString appendString:@"&"];
            }
            
            [signedString appendFormat:@"%@=%@", obj, value];
        }
    }];
    [signedString appendFormat:@"&key=%@", self.signKey];
    NSString *sign = signedString.md5.uppercaseString;
    return sign;
}

- (void)handleOpenURL:(NSURL *)url {
    [WXApi handleOpenURL:url delegate:self];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (self.paymentInfo) {
        if (QBP_STRING_IS_EMPTY(self.appId) || QBP_STRING_IS_EMPTY(self.mchId) || QBP_STRING_IS_EMPTY(self.paymentInfo.orderId)) {
            return ;
        }
        
        srand( (unsigned)time(0) );
        NSString *nonce_str  = [NSString stringWithFormat:@"%d", rand()];
        
        NSMutableDictionary *params = @{@"appid":self.appId,
                                        @"mch_id":self.mchId,
                                        @"out_trade_no":self.paymentInfo.orderId,
                                        @"nonce_str":nonce_str}.mutableCopy;
        
        NSString *sign = [self sign:params];
        [params setObject:sign forKey:@"sign"];
        
        NSDictionary *xmlParams = @{@"xml":params};
        
        @weakify(self);
        [self beginLoading];
        [[QBPaymentHttpClient sharedClient] POST:kOrderQueryUrl
                                     withXMLText:xmlParams.XMLString
                               completionHandler:^(id obj, NSError *error)
        {
            @strongify(self);
            [self endLoading];
            
            if (self.paymentInfo == nil) {
                return ;
            }
            
            QBPayResult payResult = QBPayResultFailure;
            if (obj) {
                NSDictionary *response = [NSDictionary dictionaryWithXMLData:obj];
                if ([response[@"return_code"] isEqualToString:@"SUCCESS"]
                    && [response[@"result_code"] isEqualToString:@"SUCCESS"]
                    && [response[@"trade_state"] isEqualToString:@"SUCCESS"]) {
                    payResult = QBPayResultSuccess;
                }
            }
            
            QBLog(@"WeChatPay paid with result: %@", payResult == QBPayResultSuccess ? @"SUCCESS":@"FAILURE");
            [[self class] commitPayment:self.paymentInfo withResult:payResult];
            QBSafelyCallBlock(self.paymentCompletionHandler, payResult, self.paymentInfo);
            
            self.paymentInfo = nil;
            self.paymentCompletionHandler = nil;
        }];
    }
}

- (void)onResp:(BaseResp *)resp {
    if(self.paymentInfo && [resp isKindOfClass:[PayResp class]]){

        [self endLoading];
        
        QBPayResult payResult = resp.errCode == WXSuccess ? QBPayResultSuccess : QBPayResultFailure;
        QBLog(@"WeChatPay paid with result: %@", payResult == QBPayResultSuccess ? @"SUCCESS":@"FAILURE");
        
        [[self class] commitPayment:self.paymentInfo withResult:payResult];
        QBSafelyCallBlock(self.paymentCompletionHandler, payResult, self.paymentInfo);
        
        self.paymentInfo = nil;
        self.paymentCompletionHandler = nil;
    }
}
@end
