//
//  WFTPaymentPlugin.m
//  Pods
//
//  Created by Sean Yue on 2017/6/12.
//
//

#import "WFTPaymentPlugin.h"
#import "QBSPRequestForm.h"
#import "SPHTTPManager.h"
#import "SPayClient.h"
#import "SPayClientWechatConfigModel.h"
#import "SPConst.h"
#import <XMLReader.h>
#import <MBProgressHUD.h>

@interface WFTPaymentPlugin ()
@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *signKey;
@property (nonatomic) NSString *notifyUrl;
@end

@implementation WFTPaymentPlugin

- (QBPluginType)pluginType {
    return QBPluginTypeWFTPay;
}

- (NSString *)pluginName {
    return @"威富通";
}

- (void)setPaymentConfiguration:(NSDictionary *)paymentConfiguration {
    [super setPaymentConfiguration:paymentConfiguration];
    
    self.appId = paymentConfiguration[@"appId"];
    self.mchId = paymentConfiguration[@"mchId"];
    self.signKey = paymentConfiguration[@"signKey"];
    self.notifyUrl = paymentConfiguration[@"notifyUrl"];
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler {

    if (QBP_STRING_IS_EMPTY(self.mchId) || QBP_STRING_IS_EMPTY(self.appId) || QBP_STRING_IS_EMPTY(paymentInfo.orderId) || QBP_STRING_IS_EMPTY(self.notifyUrl) || QBP_STRING_IS_EMPTY(self.signKey)) {
        QBLog(@"‼️Invalid payment configuration: %@‼️", self.paymentConfiguration);
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    [super payWithPaymentInfo:paymentInfo completionHandler:completionHandler];
    
    NSString *service = @"unified.trade.pay";
    NSString *mch_id = self.mchId;
    NSString *out_trade_no = paymentInfo.orderId;
    NSString *body = paymentInfo.orderDescription;
    NSInteger total_fee = paymentInfo.orderPrice;
    NSString *mch_create_ip = [self IPAddress];
    NSString *notify_url = self.notifyUrl;
    
    srand( (unsigned)time(0) );
    NSString *nonce_str  = [NSString stringWithFormat:@"%d", rand()];
    
    NSNumber *amount = [NSNumber numberWithInteger:total_fee];
    //生成提交表单
    NSDictionary *postInfo = [[QBSPRequestForm sharedInstance]
                              spay_pay_gateway:service
                              version:nil
                              charset:nil
                              sign_type:nil
                              sign_key:self.signKey
                              mch_id:mch_id
                              out_trade_no:out_trade_no
                              device_info:nil
                              body:body
                              total_fee:total_fee
                              mch_create_ip:mch_create_ip
                              notify_url:notify_url
                              time_start:nil
                              time_expire:nil
                              nonce_str:nonce_str
                              attach:paymentInfo.reservedData];
    
    //调用支付预下单接口
    [[SPHTTPManager sharedInstance] post:@"pay/gateway"
                                paramter:postInfo
                                 success:^(id operation, id responseObject)
     {
         //返回的XML字符串,如果解析有问题可以打印该字符串
         //        NSString *response = [[NSString alloc] initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
         
         NSError *erro;
         //XML字符串 to 字典
         //!!!! XMLReader最后节点都会设置一个kXMLReaderTextNodeKey属性
         //如果要修改XMLReader的解析，请继承该类然后再去重写，因为SPaySDK也是调用该方法解析数据，如果修改了会导致解析失败
         NSDictionary *info = [XMLReader dictionaryForXMLData:(NSData *)responseObject error:&erro];
         
         QBLog(@"预下单接口返回数据-->>\n%@",info);
         
         if (!info || ![info isKindOfClass:[NSDictionary class]]) {
             QBLog(@"预下单接口，解析数据失败");
             if (completionHandler) {
                 completionHandler(QBPayResultFailure, paymentInfo);
             }
             return ;
         }
         
         NSDictionary *xmlInfo = info[@"xml"];
         NSInteger status = [xmlInfo[@"status"][@"text"] integerValue];
         //判断SPay服务器返回的状态值是否是成功,如果成功则调起SPaySDK
         if (status != 0) {
             QBLog(@"预下单失败：%@", xmlInfo[@"message"][@"text"]);
             if (completionHandler) {
                 completionHandler(QBPayResultFailure, paymentInfo);
             }
             return ;
         }
         
         //获取SPaySDK需要的token_id
         NSString *token_id = xmlInfo[@"token_id"][@"text"];
         
         //获取SPaySDK需要的services
         //NSString *services = xmlInfo[@"services"][@"text"];
         
         //调起SPaySDK支付
         SPayClientWechatConfigModel *configModel = [[SPayClientWechatConfigModel alloc] init];
         configModel.appScheme = self.appId;
         configModel.wechatAppid = self.appId;
         [[SPayClient sharedInstance] wechatpPayConfig:configModel];
         
         [[SPayClient sharedInstance] application:[UIApplication sharedApplication]
                    didFinishLaunchingWithOptions:nil];
         
         [[SPayClient sharedInstance] pay:[self viewControllerForPresentingPayment]
                                   amount:amount
                        spayTokenIDString:token_id
                        payServicesString:kSPconstSPayWeChatService
                                   finish:^(SPayClientPayStateModel *payStateModel,
                                            SPayClientPaySuccessDetailModel *paySuccessDetailModel)
          {
              self.paymentCompletionHandler = nil;
              self.paymentInfo = nil;
              
              if (payStateModel.payState == SPayClientConstEnumPaySuccess) {
                  QBLog(@"支付成功");
                  QBLog(@"支付订单详情-->>\n%@",[paySuccessDetailModel description]);
              }else{
                  QBLog(@"支付失败，错误号:%d",payStateModel.payState);
              }
              
              if (completionHandler) {
                  completionHandler([self payResultWithPayState:payStateModel.payState], paymentInfo);
              }
              
          }];
     } failure:^(id operation, NSError *error) {
         if (completionHandler) {
             completionHandler(QBPayResultFailure, paymentInfo);
         }
         QBLog(@"调用预下单接口失败-->>\n%@",error);
     }];
}

- (QBPayResult)payResultWithPayState:(SPayClientConstEnumPayState)payState {
    QBPayResult payResult = QBPayResultFailure;
    if (payState == SPayClientConstEnumPaySuccess) {
        payResult = QBPayResultSuccess;
    } else if (payState == SPayClientConstEnumWapPayOut) {
        payResult = QBPayResultCancelled;
    }
    return payResult;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self queryPaymentInfo:self.paymentInfo withCompletionHandler:^(QBPayResult payResult, QBPaymentInfo *paymentInfo) {
        [[self class] commitPayment:paymentInfo withResult:payResult];
        QBSafelyCallBlock(self.paymentCompletionHandler, payResult, paymentInfo);
        
        self.paymentInfo = nil;
        self.paymentCompletionHandler = nil;
    }];
}

- (void)queryPaymentInfo:(QBPaymentInfo *)paymentInfo
   withCompletionHandler:(QBPaymentCompletionHandler)completionHandler
{
    if (self.paymentInfo.orderId.length == 0) {
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    srand( (unsigned)time(0) );
    NSString *nonce_str  = [NSString stringWithFormat:@"%d", rand()];
    
    NSDictionary *postInfo = [[QBSPRequestForm sharedInstance] spay_pay_gateway:@"unified.trade.query" version:nil charset:nil sign_type:nil sign_key:self.signKey mch_id:self.mchId out_trade_no:paymentInfo.orderId device_info:nil body:paymentInfo.orderDescription total_fee:0 mch_create_ip:[self IPAddress] notify_url:self.notifyUrl time_start:nil time_expire:nil nonce_str:nonce_str attach:nil];
    
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [[SPHTTPManager sharedInstance] post:@"pay/gateway" paramter:postInfo success:^(id task, id responseObject) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        NSError *erro;
        //XML字符串 to 字典
        //!!!! XMLReader最后节点都会设置一个kXMLReaderTextNodeKey属性
        //如果要修改XMLReader的解析，请继承该类然后再去重写，因为SPaySDK也是调用该方法解析数据，如果修改了会导致解析失败
        NSDictionary *info = [XMLReader dictionaryForXMLData:(NSData *)responseObject error:&erro];
        QBLog(@"查询接口返回数据-->>\n%@",info);
        
        NSString *trade_state;
        NSDictionary *xml = info[@"xml"];
        if ([xml isKindOfClass:[NSDictionary class]]) {
            NSDictionary *trade_state_dic = xml[@"trade_state"];
            if ([trade_state_dic isKindOfClass:[NSDictionary class]]) {
                trade_state = trade_state_dic[@"text"];
            }
        }
        QBPayResult payResult = [trade_state isEqualToString:@"SUCCESS"] ? QBPayResultSuccess : QBPayResultFailure;
        QBSafelyCallBlock(completionHandler, payResult, paymentInfo);
    } failure:^(id task, NSError *error) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        
        QBLog(@"查询接口返回失败:%@", error.localizedDescription);
    }];
}
@end
