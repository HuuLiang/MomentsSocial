//
//  DXTXPayPlugin.m
//  Pods
//
//  Created by Sean Yue on 2017/5/9.
//
//
#if 0

#import "DXTXPayPlugin.h"
#import "QBPaymentInfo.h"
#import "QBDefines.h"
#import "NSString+md5.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "QBPaymentQRCodeViewController.h"
#import "PayuPlugin.h"



static NSString *const kPayURL = @"https://zf.q0.cc/Pay.ashx";

@interface DXTXPayPlugin () <NSXMLParserDelegate>
@property (nonatomic,copy) QBAction didFindQRImageAction;
@end

@implementation DXTXPayPlugin

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler {
    
    NSString *appKey = self.paymentConfiguration[@"appKey"];
    NSString *notifyUrl = self.paymentConfiguration[@"notifyUrl"];
    NSNumber *waresid = self.paymentConfiguration[@"waresid"];
    
    if (QBP_STRING_IS_EMPTY(appKey) || QBP_STRING_IS_EMPTY(notifyUrl) || !waresid
        || QBP_STRING_IS_EMPTY(paymentInfo.orderId) || paymentInfo.orderPrice == 0) {
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    if (paymentInfo.pluginType == QBPluginTypeDXTXPay) {
        
        [[PayuPlugin defaultPlugin] payWithViewController:[QBPaymentUtil viewControllerForPresentingPayment]
                                             o_paymode_id:PayTypeWXApp
                                                O_bizcode:paymentInfo.orderId
                                               o_goods_id:waresid.intValue
                                             o_goods_name:paymentInfo.orderDescription
                                                  o_price:paymentInfo.orderPrice/100.
                                                o_address:notifyUrl
                                            o_showaddress:nil
                                            o_privateinfo:paymentInfo.reservedData
                                                   Scheme:self.urlScheme
                                                   AppKey:appKey
                                            completeBlock:^(NSDictionary *result)
         {
             QBLog(@"DXTX payment response: %@", result);
             
             NSInteger code = [result[@"resultStatus"] integerValue];
             QBPayResult payResult = QBPayResultFailure;
             if (code == 6001) {
                 payResult = QBPayResultCancelled;
             } else if (code == 9000) {
                 payResult = QBPayResultSuccess;
             }
             QBSafelyCallBlock(completionHandler, payResult, paymentInfo);
         }];
    } else if (paymentInfo.paymentType == QBPayTypeDXTXScanPay && paymentInfo.paymentSubType == QBPaySubTypeWeChat) {
        [self WXScanPayWithPaymentInfo:paymentInfo completionHandler:completionHandler];
    } else {
        QBSafelyCallBlock(completionHandler,QBPayResultFailure, paymentInfo);
    }

}

- (void)WXScanPayWithPaymentInfo:(QBPaymentInfo *)paymentInfo
               completionHandler:(QBPaymentCompletionHandler)completionHandler {
    NSString *appKey = self.paymentConfiguration[@"appKey"];
    NSString *notifyUrl = self.paymentConfiguration[@"notifyUrl"];
    NSNumber *waresid = self.paymentConfiguration[@"waresid"];
    
    NSDictionary *params = @{@"o_bizcode":paymentInfo.orderId,
                             @"o_appkey":appKey,
                             @"o_term_key":[QBPaymentUtil IPAddress].md5,
                             @"o_address":notifyUrl,
                             @"o_paymode_id":@6,
                             @"o_goods_id":waresid,
                             @"o_goods_name":paymentInfo.orderDescription ?: @"VIP",
                             @"o_price":@(paymentInfo.orderPrice/100.),
                             @"o_privateinfo":paymentInfo.reservedData ?: @""};
    
    NSString *paramString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    [self.sessionManager POST:kPayURL
                   parameters:@{@"Pay":paramString?:@""}
                     progress:nil
                      success:^(NSURLSessionDataTask * _Nonnull task,
                                id  _Nullable responseObject)
     {
         
         self.didFindQRImageAction = ^(id obj) {
             [QBPaymentQRCodeViewController presentQRCodeInViewController:[QBPaymentUtil viewControllerForPresentingPayment] withImage:obj paymentCompletion:^(BOOL isManual, id qrVC) {
                 QBPaymentQRCodeViewController *thisVC = qrVC;
                 [MBProgressHUD showHUDAddedTo:thisVC.view animated:YES];
                 [qrVC setEnableCheckPayment:NO];
                 
                 [QBPaymentUtil checkPaymentResultWithPaymentInfos:@[paymentInfo] retryTimes:3 completionHandler:^(QBPayResult payResult, QBPaymentInfo *paymentInfo) {
                     [MBProgressHUD hideHUDForView:thisVC.view animated:YES];
                     [qrVC setEnableCheckPayment:YES];
                     
                     if (payResult == QBPayResultSuccess) {
                         [qrVC dismissViewControllerAnimated:YES completion:^{
                             QBSafelyCallBlock(completionHandler, QBPayResultSuccess, paymentInfo);
                         }];
                     } else {
                         QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
                     }
                 }];
//                 [[QBPaymentManager sharedManager] activatePaymentInfo:paymentInfo withRetryTimes:3 shouldCommitFailureResult:!isManual completionHandler:^(BOOL success, id obj) {
//                     [MBProgressHUD hideHUDForView:thisVC.view animated:YES];
//                     [qrVC setEnableCheckPayment:YES];
//                     
//                     if (success) {
//                         [qrVC dismissViewControllerAnimated:YES completion:^{
//                             QBSafelyCallBlock(completionHandler, QBPayResultSuccess, paymentInfo);
//                         }];
//                     } else {
//                         QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
//                     }
//                 }];
             } refreshAction:nil];
         };
         
         
         NSXMLParser *parser = [[NSXMLParser alloc] initWithData:responseObject];
         parser.delegate = self;
         [parser parse];
         
         [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         QBLog(@"%@ prepay fails: %@", [self class], error.localizedDescription);
         [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
         QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
     }];
}

- (void)handleOpenURL:(NSURL *)url {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    if ([elementName isEqualToString:@"img"]) {
        [parser abortParsing];
        
        __block NSString *imageString;
        NSString *prefix = @"base64,";
        
        NSArray<NSString *> *comps = [attributeDict[@"src"] componentsSeparatedByString:@";"];
        [comps enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj hasPrefix:prefix]) {
                imageString = [obj substringFromIndex:prefix.length];
                *stop = YES;
            }
        }];
        
        if (imageString.length == 0) {
            return ;
        }
        
        NSData *data = [[NSData alloc] initWithBase64EncodedString:imageString options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (data) {
            UIImage *image = [[UIImage alloc] initWithData:data];
            if (image) {
                QBSafelyCallBlock(self.didFindQRImageAction, image);
            }
        }
    }
}
@end
#endif