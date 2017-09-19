//
//  QBPaymentDefines.h
//  Pods
//
//  Created by Sean Yue on 16/9/13.
//
//

#ifndef QBPaymentDefines_h
#define QBPaymentDefines_h

#import "QBDefines.h"

typedef NS_ENUM(NSUInteger, QBPluginType) {
    QBPluginTypeNone,
    QBPluginTypeAlipay = 1001,
    QBPluginTypeWeChatPay = 1008,
    QBPluginTypeIAppPay = 1009, //爱贝支付
    QBPluginTypeVIAPay = 1010, //首游时空
    QBPluginTypeWFTPay = 1012, //威富通
    QBPluginTypeHTPay = 1015, //海豚支付
    QBPluginTypeMTDLPay = 1017, //明天动力
    QBPluginTypeMingPay = 1018, //明鹏支付
    QBPluginTypeWJPay = 1020, // 无极支付
    QBPluginTypeWeiYingPay = 1022, //微赢支付
    QBPluginTypeXLTXPay = 1023, //星罗天下
    QBPluginTypeJSPay = 1028, //杰莘
    QBPluginTypeHeePay = 1029,     //汇付宝
    QBPluginTypeMLYPay = 1030, // 萌乐游
    QBPluginTypeLSPay = 1031, // 雷胜app支付
    QBPluginTypeRMPay = 1032, // 融梦支付
    QBPluginTypeZRPay = 1033, // 中润付(甬润支付)
    QBPluginTypeYiPay = 1034, // 易支付
    QBPluginTypeLSScanPay = 1035, //雷胜扫码支付
    QBPluginTypeDXTXScanPay = 1036, //盾行天下扫码支付
    QBPluginTypeLePay = 1037,    //乐Pay
    QBPluginTypeJiePay = 1038,   //捷支付
    QBPluginTypeHaiJiaPay = 1039, //海嘉支付
    QBPluginTypeDmePay = 1040, // DmePay
    QBPluginTypeHuiPay = 1041, //惠付支付
    QBPluginTypeDXTXPay = 1042, //盾行天下
    QBPluginTypeZYPay = 1045, //卓越支付
    QBPluginTypeXinPay = 1046, //鑫支付
    QBPluginTypeBNPay = 1047, //博诺支付
    QBPluginTypeZGBNPay = 1049, //中光倍能
    QBPluginTypeWeiPay = 1050, //微支付
    QBPluginTypeXXBPay = 1051, //小小贝支付
    QBPluginTypeBBPay = 1052, //贝贝支付
    QBPluginTypeUnknown = 9999
};

typedef NSUInteger QBPayPointType;

//typedef NS_ENUM(NSUInteger, QBPayPointType) {
//    QBPayPointTypeNone,
//    QBPayPointTypeVIP,
//    QBPayPointTypeSVIP
//};

typedef NS_ENUM(NSUInteger, QBPaymentType) {
    QBPaymentTypeNone,
    QBPaymentTypeWeChat,
    QBPaymentTypeAlipay,
    QBPaymentTypeUPPay,
    QBPaymentTypeQQ
};

typedef NS_ENUM(NSInteger, QBPayResult)
{
    QBPayResultSuccess   = 0,
    QBPayResultFailure   = 1,
    QBPayResultCancelled = 2,
    QBPayResultUnknown   = 3
};

typedef NS_ENUM(NSUInteger, QBPayStatus) {
    QBPayStatusUnknown,
    QBPayStatusPaying,
    QBPayStatusNotProcessed,
    QBPayStatusProcessed
};

@class QBPaymentInfo;
typedef void (^QBPaymentCompletionHandler)(QBPayResult payResult, QBPaymentInfo *paymentInfo);

#define QBPDEPRECATED(desc) __attribute__((unavailable(desc)))

#define QBP_STRING_IS_EMPTY(str) ([str length]==0)
#define QBP_STRING_IS_NOT_EMPTY(str) ([str length]>0)

#define QBP_XML_CDATA(rdata) [NSString stringWithFormat:@"<![CDATA[%@]]>", rdata]
#define QBP_XML_RAWDATA(cdata) ([cdata hasPrefix:@"<![CDATA["] ? [cdata substringWithRange:NSMakeRange(9, [cdata length]-12)] : cdata)

#endif /* QBPaymentDefines_h */
