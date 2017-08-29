//
//  YiPaymentPlugin.m
//  Pods
//
//  Created by Sean Yue on 2017/6/13.
//
//

#import "YiPaymentPlugin.h"
#import <NSString+md5.h>
#import <MBProgressHUD.h>
#import "QBPaymentHttpClient.h"
#import "QBPaymentWebViewController.h"
#import "QBPaymentQRCodeViewController.h"

@interface YiPaymentPlugin ()
@property (nonatomic) NSString *payUrl;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *key;
@end

@implementation YiPaymentPlugin

- (QBPluginType)pluginType {
    return QBPluginTypeYiPay;
}

- (NSString *)pluginName {
    return @"易支付";
}

- (BOOL)shouldRequirePhotoLibraryAuthorization {
    return YES;
}

- (void)setPaymentConfiguration:(NSDictionary *)paymentConfiguration {
    [super setPaymentConfiguration:paymentConfiguration];
    
    self.payUrl = paymentConfiguration[@"payUrl"];
    self.mchId = paymentConfiguration[@"mchId"];
    self.appId = paymentConfiguration[@"appId"];
    self.key = paymentConfiguration[@"key"];
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler {
    if (QBP_STRING_IS_EMPTY(self.payUrl) || QBP_STRING_IS_EMPTY(self.mchId) || QBP_STRING_IS_EMPTY(self.appId) || QBP_STRING_IS_EMPTY(self.key)) {
        QBLog(@"Invalid payment configuration: %@", self.paymentConfiguration);
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    if (paymentInfo.orderPrice == 0 || QBP_STRING_IS_EMPTY(paymentInfo.orderId) || (paymentInfo.paymentType != QBPaymentTypeWeChat && paymentInfo.paymentType != QBPaymentTypeAlipay)) {
        QBLog(@"Invalid payment info: %@", paymentInfo.description);
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    NSString *orderId = [NSString stringWithFormat:@"%@$%@", paymentInfo.orderId, paymentInfo.reservedData];
    NSString *orderDesc = paymentInfo.orderDescription ?: @"商品";
    NSMutableDictionary *params = @{@"subject":orderDesc,
                                    @"total_fee":@(paymentInfo.orderPrice),
                                    @"body":orderDesc,
                                    //@"paychannel":paymentInfo.paymentSubType == QBPaySubTypeAlipay ? @"pay_alipay_wap" : @"YFtencent_app",
                                    @"pay_type":paymentInfo.paymentType == QBPaymentTypeAlipay ? @"pay_alipay_wap" : @"pay_weixin_scan",
                                    @"mchNo":self.mchId,
                                    @"tag":@"470",
                                    @"version":@"1.0",
                                    @"appid":self.appId,
                                    @"mchorderid":orderId,
                                    @"show_url":@"www.baidu.com",
                                    @"mch_app_id":[NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"],
                                    @"device_info":@"IOS_WAP",
                                    @"ua":@"App/WebView",
                                    @"mch_app_name":[NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"],
                                    @"callback_url":@"www.baidu.com"}.mutableCopy;
    
    //    if (paymentInfo.paymentSubType == QBPaySubTypeAlipay) {
    //        [params addEntriesFromDictionary:@{@"show_url":@"www.baidu.com",
    //                                           @"mch_app_id":[NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"],
    //                                           @"device_info":@"IOS_WAP",
    //                                           @"ua":@"AppleWebKit/537.36",
    //                                           @"mch_app_name":[NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"],
    //                                           @"callback_url":@"www.baidu.com"}];
    //    } else {
    //        [params addEntriesFromDictionary:@{@"appName":[NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"],
    //                                           @"ua":[QBPaymentUtil deviceName] ?: @"",
    //                                           @"os":@"ios",
    //                                           @"packagename":[NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"]}];
    //    }
    
    
    NSMutableString *str = [NSMutableString string];
    NSArray *signedKeys = [params.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    [signedKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = params[obj];
        [str appendFormat:@"%@=%@&", obj, value];
    }];
    
    [str appendFormat:@"key=%@", self.key];
    [params setObject:str.md5 forKey:@"sign"];
    
    @weakify(self);
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [[QBPaymentHttpClient JSONRequestClient] POST:self.payUrl withParams:params completionHandler:^(id obj, NSError *error) {
        @strongify(self);
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        if (error) {
            QBLog(@"YiPay fails: %@", error.localizedDescription);
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            return ;
        }
    
        id jsonObj = [NSJSONSerialization JSONObjectWithData:obj options:NSJSONReadingAllowFragments error:nil];
        
        NSNumber *errorCode = jsonObj[@"errorcode"];
        if (!errorCode || errorCode.integerValue != 0) {
            QBLog(@"YiPay fails: \n%@", jsonObj);
            QBLog(@"YiPay fails: %@", jsonObj[@"errormsg"]);
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            return ;
        }
        
        if (paymentInfo.paymentType == QBPaymentTypeAlipay) {
            NSString *content = jsonObj[@"content"];
            if (content.length == 0) {
                QBLog(@"YiPay fails: response content is empty!");
                QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
                return ;
            }
            
            self.paymentInfo = paymentInfo;
            self.paymentCompletionHandler = completionHandler;
            
            QBLog(@"YiPay wap open URL: %@", content);
            QBPaymentWebViewController *webVC = [[QBPaymentWebViewController alloc] initWithURL:[NSURL URLWithString:content]];
            webVC.capturedAlipayRequest = ^(NSURL *url, id obj) {
                [[UIApplication sharedApplication] openURL:url];
            };
            [[self viewControllerForPresentingPayment] presentViewController:webVC animated:YES completion:nil];
            
            self.payingViewController = webVC;
            
        } else { //QBPaySubTypeWeChat
            NSString *imgUrl = jsonObj[@"code_img_url"];
            if (QBP_STRING_IS_EMPTY(imgUrl)) {
                QBLog(@"%@ QR image url error response !", [self class]);
                QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
                return ;
            }
            
            [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
            
            [[QBPaymentHttpClient JSONRequestClient] GET:imgUrl withParams:nil completionHandler:^(id obj, NSError *error) {
                @strongify(self);
                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
                
                if (error) {
                    QBLog(@"%@ QR image parse fails: %@", [self class], error.localizedDescription);
                    QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
                    return ;
                }
                
                UIImage *image = [[UIImage alloc] initWithData:obj];
                if (!image) {
                    QBLog(@"%@ QR image url error response ! URL: %@", [self class], imgUrl);
                    QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
                    return ;
                }
                
                [QBPaymentQRCodeViewController presentQRCodeInViewController:[self viewControllerForPresentingPayment]
                                                                   withImage:image
                                                           paymentCompletion:^(BOOL isManual, id qrVC)
                 {
                     @strongify(self);
                     QBPaymentQRCodeViewController *thisVC = qrVC;
                     [MBProgressHUD showHUDAddedTo:thisVC.view animated:YES];
                     [qrVC setEnableCheckPayment:NO];
                     
                     [self queryPaymentResultForPaymentInfo:paymentInfo withRetryTimes:3 completionHandler:^(QBPayResult payResult, QBPaymentInfo *paymentInfo) {
                         [MBProgressHUD hideHUDForView:thisVC.view animated:YES];
                         [qrVC setEnableCheckPayment:YES];
                         
                         if (payResult == QBPayResultSuccess) {
                             [[self class] commitPayment:paymentInfo withResult:QBPayResultSuccess];
                             
                             [qrVC dismissViewControllerAnimated:YES completion:^{
                                 QBSafelyCallBlock(completionHandler, QBPayResultSuccess, paymentInfo);
                             }];
                             
                         } else {
                             if (!isManual) {
                                 [[self class] commitPayment:paymentInfo withResult:QBPayResultFailure];
                             }
                             QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
                         }
                     }];
                 } refreshAction:nil];
            }];
        }
        
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (self.paymentInfo.paymentType == QBPaymentTypeAlipay) {
        [super applicationWillEnterForeground:application];
    }
}

@end
