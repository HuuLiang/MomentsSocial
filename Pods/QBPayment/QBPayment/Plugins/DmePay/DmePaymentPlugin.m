//
//  DmePaymentPlugin.m
//  Pods
//
//  Created by Sean Yue on 2017/7/24.
//
//

#import "DmePaymentPlugin.h"
#import <DmePaySDK/DmePayAPI.h>
#import <MBProgressHUD.h>

@interface DmePaymentPlugin ()
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *mchName;
@property (nonatomic) NSString *key;
@end

@implementation DmePaymentPlugin

- (NSString *)pluginName {
    return @"Dme支付";
}

- (QBPluginType)pluginType {
    return QBPluginTypeDmePay;
}

- (void)pluginDidLoad {
    
#ifdef DEBUG
    static NSString *const kWeChatUrlScheme = @"wx7582624643d84dd6";
    static NSString *const kAlipayUrlScheme = @"dme2024ba6f404f";
    
    __block BOOL hasWeChatUrlSchemes = NO;
    __block BOOL hasAlipayUrlSchemes = NO;
    NSArray<NSDictionary *> *urlTypes = [NSBundle mainBundle].infoDictionary[@"CFBundleURLTypes"];
    [urlTypes enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *urlSchemes = obj[@"CFBundleURLSchemes"];
        [urlSchemes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            hasWeChatUrlSchemes = hasWeChatUrlSchemes || [obj isEqualToString:kWeChatUrlScheme];
            hasAlipayUrlSchemes = hasAlipayUrlSchemes || [obj isEqualToString:kAlipayUrlScheme];
            
            if (hasWeChatUrlSchemes && hasAlipayUrlSchemes) {
                *stop = YES;
            }
        }];
        
        if (hasWeChatUrlSchemes && hasAlipayUrlSchemes) {
            *stop = YES;
        }
    }];
    
    if (!hasWeChatUrlSchemes) {
        QBLog(@"⚠️DmePay: WeChat url scheme is not configured⚠️");
    }
    
    if (!hasAlipayUrlSchemes) {
        QBLog(@"⚠️DmePay: Alipay url scheme is not configured⚠️");
    }
#endif
}

- (void)pluginDidSetPaymentConfiguration:(NSDictionary *)paymentConfiguration {
    self.mchId = paymentConfiguration[@"mchId"];
    self.mchName = paymentConfiguration[@"mchName"];
    self.key = paymentConfiguration[@"key"];
    
    if (QBP_STRING_IS_NOT_EMPTY(self.mchId) && QBP_STRING_IS_NOT_EMPTY(self.mchName) && QBP_STRING_IS_NOT_EMPTY(self.key)) {
        [DmePayAPI init:self.mchId partnername:self.mchName partnertoken:self.key];
    }
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler {
    if (QBP_STRING_IS_EMPTY(self.mchId) || QBP_STRING_IS_EMPTY(self.key) || QBP_STRING_IS_EMPTY(self.mchName)
        || QBP_STRING_IS_EMPTY(paymentInfo.orderId) || QBP_STRING_IS_EMPTY(paymentInfo.orderDescription)) {
        QBLog(@"DmePay error with invalid parameters");
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    self.paymentInfo = paymentInfo;
    self.paymentCompletionHandler = completionHandler;
    
    @weakify(self);
    NSString *comment;
    if (QBP_STRING_IS_NOT_EMPTY(paymentInfo.reservedData)) {
        comment = [NSString stringWithFormat:@"%@$%@", paymentInfo.orderId, paymentInfo.reservedData];
    }
    
    [self beginLoading];
    [self performSelector:@selector(endLoading) withObject:nil afterDelay:10];
    
    [DmePayAPI startPay:paymentInfo.orderDescription goodsid:paymentInfo.orderId goodsfee:[NSString stringWithFormat:@"%.2f", paymentInfo.orderPrice/100.] goodscomment:comment?:@"" paytype:paymentInfo.paymentType == QBPaymentTypeAlipay ? kPTAlipay : kPTWeixinPay callback:^(int status, NSString *description)
    {
        @strongify(self);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self endLoading];
            
            if (status != 0) {
                QBLog(@"DmePay Error: %@", description);
                [[self class] commitPayment:paymentInfo withResult:QBPayResultFailure];
                QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
                
                self.paymentInfo = nil;
                self.paymentCompletionHandler = nil;
            }
        });
        
    }];
}

- (void)handleOpenURL:(NSURL *)url {
    [DmePayAPI handleOpenUrl:url];
}
@end
