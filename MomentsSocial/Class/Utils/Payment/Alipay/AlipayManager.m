//
//  AlipayManager.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "AlipayManager.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>


static AlipayManager *alipayManager;

@interface AlipayManager ()
@property (nonatomic,copy) AlipayResultBlock resultBlock;
@property (nonatomic,retain) Order *payOrder;
@end

@implementation AlipayManager
{
}



#pragma mark - shareInstance
+ (AlipayManager *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        alipayManager = [[AlipayManager alloc] init];
    });
    return alipayManager;
}



#pragma mark -  function
/*!
 *	@brief 支付宝支付接口
 *  @param orderId  订单的id ，在调用创建订单之后服务器会返回该订单的id
 *  @param price    商品价格
 *  @result
 */
- (void)startAlipay:(NSString *)_orderId price:(NSUInteger)_price withResult:(AlipayResultBlock)resultBlock
{
    self.resultBlock = resultBlock;
    
//    NSString *appName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
//    if (!appName) {
//        appName = @"家庭影院";
//    }
//    
    Order *order = [[Order alloc] init];
    order.partner       = @"2088121511256613";
    order.seller        = @"wuyp@iqu8.cn";
    
    order.tradeNO       = _orderId;         //订单ID（由商家自行制定）
    order.productName   = @"同城速配增值服务"; //商品标题
    order.productDescription = MS_PAYMENT_RESERVE_DATA; //商品描述
    order.amount        = [NSString stringWithFormat:@"%.2f", _price/100.];           //商品价格
    order.notifyURL     =  @"http://phas.rdgongcheng.cn/pd-has/notifyByAlipay.json"; //回调URL
    
    order.service       = @"mobile.securitypay.pay";
    order.paymentType   = @"1";
    order.inputCharset  = @"utf-8";
    order.itBPay        = @"30m";
    order.showUrl       = @"m.alipay.com";
    
    
    
    
    NSString *orderInfo = [order description];
    NSString *appScheme = MS_AliPay_SchemeUrl;
//
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer   = CreateRSADataSigner(@"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAKxJu4mHp7puorftVMcIhUU4qdQRalHFyp7/yXOKYJ2dv6+9xtZWJVAedQfoWwfjBfGb7r9sOVjG8otwi/1+pwu4u9BpdQxfV5VkFclf/wjSLbe4191udy9UuFO2gXNGmN2GC7/28MeY8LGH9kcIEsTJI5iB1yz42grnnk+rYysvAgMBAAECgYBzgHrZmLg5pDIyXEmZpXyzC2nPYl2EtLVCIvlLHFnpUPhROUk0KEybic+rnXppryks8Pz+F+/aNIYmNS2kpGQXuZa9yLDyTzy38iqqHGtOUVBMDuHyvNM4qBepn065uhQqhA3O5IndSBUXNRMMovab7qdJdqLLMuPWAFBTAk6vAQJBAPrRQhC2+BsSbaZe1Tqv6PQK7uN4hK23zPVhy5xQ6YaeTtIIIkGK4j/1vnObiVqCE1HPryEUlhljaG6TJ2q9h/sCQQCv2RRo4Mne8Eb6e67uLj8GavUHEuQ6GAK/01oZ3H0FEmWK2kyuWuJyOxfwH3BbsYPw4FtQGCkcuAciHp9Jlj9dAkEApW8+7z1wGpMmJdVpOYNr2QQZG4qToO2Zz8RIg3tO/M8QWDKrPaX4o41YqHJPv5YKXizpa51jf6105XJEToBi3wJAM+KARCW3SqFov/WIetyIWhNq8shfMMju3ry0xBariLiR33Nj1roYQI4xFPehxlxNSuBX8Pz//GpMKIQSibrcPQJAaTHHXGWr5Qh5dgOjs9CspivZYeSlLDbHePFsRLzXeRbsQD/Xsh4a9n0n0tOnIUSn71HjYlX9bEF+3RwvDZlcPw==");
    NSString *signedString  = [signer signString:orderInfo];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil)
    {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderInfo, signedString, @"RSA"];
        
        self.payOrder = order;
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic)
        {
            [self sendNotificationByResult:resultDic];
        }];
    }
    
}


- (void)sendNotificationByResult:(NSDictionary *)_resultDic
{
    QBLog(@"支付宝返回的result : %@" , _resultDic);
    MSPayResult payResult = MSPayResultFailed;
    //用户放弃付款的情况  6001
    if([[_resultDic allKeys] containsObject:@"resultStatus"])
    {
        NSString * resultStatues  = _resultDic[@"resultStatus"];
        if([resultStatues isEqualToString:@"6001"]) {
            payResult = MSPayResultCancle;
        } else if ([resultStatues isEqualToString:@"9000"]) {
            payResult = MSPayResultSuccess;
        } else {
            payResult = MSPayResultFailed;
        }
    }
    
    if (self.resultBlock) {
        self.resultBlock(payResult, self.payOrder);
    }
}

@end
