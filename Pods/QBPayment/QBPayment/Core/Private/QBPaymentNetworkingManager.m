//
//  QBPaymentNetworkingManager.m
//  Pods
//
//  Created by Sean Yue on 2017/6/2.
//
//

#import "QBPaymentNetworkingManager.h"
#import "QBPaymentHttpClient.h"
#import "NSString+md5.h"
#import "NSString+crypt.h"
#import "NSObject+BaseRepresentation.h"
#import "QBPaymentInfo.h"
#import "QBPaymentConfiguration.h"
#import "QBPayPoint.h"

static NSString *const kQBPaymentNetworkingSignKey = @"qdge^%$#@(sdwHs^&";
static NSString *const kQBPaymentCryptPassword = @"wdnxs&*@#!*qb)*&qiang";

static NSString *const kQBPaymentTestServer = @"http://120.24.252.114:8084/paycenter";
static NSString *const kQBPaymentProductionServer = @"http://pay.rdgongcheng.cn/paycenter";

static NSString *const kQBPaymentConfigurationURL = @"/appPayConfig.json";
static NSString *const kQBPayPointsURL = @"/v3/payPoints.json";

static NSString *const kQBPaymentCommitURL = @"/qubaPr.json";
static NSString *const kQBPaymentConfigurationStandbyURL = @"http://sts-src.ayyygs.com/paycenter/appPayConfig-%@-%@.json";
static NSString *const kQBPayPointsStandbyURL = @"http://sts-src.ayyygs.com/paycenter/payPoints-%@-v3.json";

static NSString *const kQBQueryOrderServer = @"http://phas.rdgongcheng.cn/pd-has";
static NSString *const kQBQueryOrderURL = @"/successOrderIds.json";

static NSString *const kQBPaymentConfigCacheFile = @"paymentconfiguration";
static NSString *const kQBPayPointsCacheFile = @"paypoints";

//static NSString *const kQBPaymentNetworkingVersion = @"v2";

@interface QBPaymentNetworkingManager ()
@property (nonatomic,retain) dispatch_queue_t cacheQueue;
@property (nonatomic,retain) NSString *paymentConfigurationCachedPath;
@property (nonatomic,retain) NSString *payPointsCachedPath;
@end

@implementation QBPaymentNetworkingManager

QBSynthesizeSingletonMethod(defaultManager)

- (dispatch_queue_t)cacheQueue {
    if (_cacheQueue) {
        return _cacheQueue;
    }
    
    _cacheQueue = dispatch_queue_create("com.qbpayment.QBPaymentNetworkingManager.cachequeue", nil);
    return _cacheQueue;
}

- (NSString *)paymentConfigurationCachedPath {
    if (_paymentConfigurationCachedPath) {
        return _paymentConfigurationCachedPath;
    }
    
    NSArray<NSString *> *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if (cachePaths.firstObject) {
        _paymentConfigurationCachedPath = [NSString stringWithFormat:@"%@/%@", cachePaths.firstObject, kQBPaymentConfigCacheFile.md5];
    }
    return _paymentConfigurationCachedPath;
}

- (NSString *)payPointsCachedPath {
    if (_payPointsCachedPath) {
        return _payPointsCachedPath;
    }
    
    NSArray<NSString *> *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if (cachePaths.firstObject) {
        _payPointsCachedPath = [NSString stringWithFormat:@"%@/%@", cachePaths.firstObject, kQBPayPointsCacheFile.md5];
    }
    return _payPointsCachedPath;
}

- (NSString *)absoluteURLStringWithURLPath:(NSString *)urlPath forTest:(BOOL)isTest {
    return [NSString stringWithFormat:@"%@%@", isTest ? kQBPaymentTestServer : kQBPaymentProductionServer, urlPath];
}

- (BOOL)validateParametersForSigning {
    return QBP_STRING_IS_NOT_EMPTY(self.appId) && QBP_STRING_IS_NOT_EMPTY(self.channelNo) && self.pv;
}

- (void)request_commitPaymentInfo:(QBPaymentInfo *)paymentInfo withCompletionHandler:(QBCompletionHandler)completionHandler {
    if (![self validateParametersForSigning] || !paymentInfo.userId || QBP_STRING_IS_EMPTY(paymentInfo.orderId)) {
        QBSafelyCallBlock(completionHandler, NO, nil);
        return ;
    }
    
    NSDictionary *statusDic = @{@(QBPayResultSuccess):@(1), @(QBPayResultFailure):@(0), @(QBPayResultCancelled):@(2), @(QBPayResultUnknown):@(0)};
    NSDictionary *paymentSubTypeDic = @{@(QBPaymentTypeWeChat):@"WEIXIN",
                                        @(QBPaymentTypeAlipay):@"ALIPAY",
                                        @(QBPaymentTypeUPPay):@"UNIONPAY",
                                        @(QBPaymentTypeQQ):@"QQPAY"};
    
    NSString *appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    
    NSDictionary *params = @{@"uuid":paymentInfo.userId,
                             @"orderNo":paymentInfo.orderId,
                             @"imsi":@"999999999999999",
                             @"imei":@"999999999999999",
                             @"payMoney":@(paymentInfo.orderPrice).stringValue,
                             @"channelNo":self.channelNo,
                             @"contentId":paymentInfo.contentId.stringValue ?: @"0",
                             @"contentType":paymentInfo.contentType.stringValue ?: @"0",
                             @"pluginType":@(paymentInfo.paymentType),
                             @"payType":paymentSubTypeDic[@(paymentInfo.paymentType)] ?: @"",
                             @"payPointType":@(paymentInfo.currentPayPointType * 10 + paymentInfo.targetPayPointType),
                             @"appId":self.appId,
                             @"versionNo":@(appVersion.integerValue),
                             @"status":statusDic[@(paymentInfo.paymentResult)],
                             @"pV":self.pv,
                             @"payTime":paymentInfo.paymentTime};
    
    [[QBPaymentHttpClient sharedClient] POST:[self absoluteURLStringWithURLPath:kQBPaymentCommitURL forTest:NO]
                                  withParams:[self encryptParams:params]
                           completionHandler:^(id obj, NSError *error)
    {
        NSDictionary *decryptedResponse = [self decryptResponse:obj];
        QBLog(@"Payment response : %@", decryptedResponse);
        
        NSNumber *respCode = decryptedResponse[@"response_code"];
        BOOL success = respCode.unsignedIntegerValue == 100;
        if (success) {
            paymentInfo.paymentStatus = QBPayStatusProcessed;
            [paymentInfo save];
        } else {
            QBLog(@"‼️Payment: fails to commit the order with orderId:%@‼️", paymentInfo.orderId);
        }
        QBSafelyCallBlock(completionHandler, success, respCode);
    }];
}

- (void)request_fetchPaymentConfigurationWithCompletionHandler:(QBCompletionHandler)completionHandler
{
    if (![self validateParametersForSigning]) {
        QBSafelyCallBlock(completionHandler, NO, nil);
        return ;
    }
    
    QBCompletionHandler successHandler = ^(BOOL usingCache, id obj) {
        NSDictionary *response = [self decryptResponse:obj];
        QBLog(@"Fetch payment configuration with response:\n%@", response);
        
        NSNumber *code = response[@"code"];
        if (!code || code.unsignedIntegerValue != 100) {
            QBSafelyCallBlock(completionHandler, NO, response);
            return ;
        }
        
        QBPaymentConfiguration *config = [QBPaymentConfiguration objectFromDictionary:response];
        if (config && !usingCache) {
            dispatch_async(self.cacheQueue, ^{
                BOOL isCached = [(NSDictionary *)obj writeToFile:self.paymentConfigurationCachedPath atomically:YES];
                if (isCached) {
                    QBLog(@"✅Cached payment configuration to path : %@!✅", self.paymentConfigurationCachedPath);
                } else {
                    QBLog(@"‼️Fail to cache payment configuration to path : %@‼️", self.paymentConfigurationCachedPath);
                }
                
            });
        }
        QBSafelyCallBlock(completionHandler, config != nil, config);
    };
    
    QBPaymentHttpCompletionHandler handler = ^(id obj, NSError *error) {
        if (error) {
            QBSafelyCallBlock(completionHandler, NO, nil);
        } else {
            successHandler(NO, obj);
        }
    };
    
    NSDictionary *encryptedParams = [self encryptParams:@{@"appId":self.appId,
                                                          @"channelNo":self.channelNo,
                                                          @"pv":self.pv}];
    
    @weakify(self);
    [[QBPaymentHttpClient sharedClient] POST:[self absoluteURLStringWithURLPath:kQBPaymentConfigurationURL forTest:self.useTestServer]
                                  withParams:encryptedParams
                           completionHandler:^(id obj, NSError *error)
    {
        @strongify(self);
        if (error) {
            [[QBPaymentHttpClient sharedClient] GET:[NSString stringWithFormat:kQBPaymentConfigurationStandbyURL, self.appId, self.pv]
                                         withParams:nil
                                  completionHandler:^(id obj, NSError *error) {
                                      if (error) {
                                          NSDictionary *cachedConfig = [[NSDictionary alloc] initWithContentsOfFile:self.paymentConfigurationCachedPath];
                                          if (cachedConfig) {
                                              successHandler(YES, cachedConfig);
                                          } else {
                                              handler(obj, error);
                                          }
                                      } else {
                                          handler(obj, error);
                                      }
                                  }];
        } else {
            handler(obj, error);
        }
    }];
}

- (void)request_fetchPayPointsWithCompletionHandler:(QBCompletionHandler)completionHandler {
    if (QBP_STRING_IS_EMPTY(self.appId) || !self.payPointVersion || QBP_STRING_IS_EMPTY(self.channelNo)) {
        QBSafelyCallBlock(completionHandler, NO, nil);
        return ;
    }
    
    QBCompletionHandler success = ^(BOOL usingCache, id obj) {
        
        QBLog(@"✅Fetched pay points: %@ %@✅", obj, usingCache ? @"by cache" : @"");
        
        
        NSMutableDictionary *payPoints = [[NSMutableDictionary alloc] init];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary<NSString *, NSArray<NSDictionary *> *> *response = obj;
            [response enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray<NSDictionary *> * _Nonnull obj, BOOL * _Nonnull stop) {
                if (![obj isKindOfClass:[NSArray class]]) {
                    return ;
                }
                
                NSArray<QBPayPoint *> *arr = [QBPayPoint objectsFromArray:obj];
                [payPoints setObject:arr forKey:key];
            }];
        }
        
        
//        NSArray *data = obj;
//        NSMutableArray<QBPayPoint *> *payPoints = [NSMutableArray arrayWithCapacity:data.count];
//        [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj isKindOfClass:[NSDictionary class]]) {
//                QBPayPoint *payPoint = [QBPayPoint objectFromDictionary:obj];
//                if (payPoint) {
//                    [payPoints addObject:payPoint];
//                }
//            }
//        }];
//        
        if (payPoints.count > 0 && !usingCache) {
            dispatch_async(self.cacheQueue, ^{
                BOOL isCached = [(NSDictionary *)obj writeToFile:self.payPointsCachedPath atomically:YES];
                if (isCached) {
                    QBLog(@"✅Cached pay points to path : %@!✅", self.paymentConfigurationCachedPath);
                } else {
                    QBLog(@"‼️Fail to cache pay points to path : %@‼️", self.paymentConfigurationCachedPath);
                }
                
            });
        }
        QBSafelyCallBlock(completionHandler, YES, payPoints);
    };
    
    NSDictionary *encryptedParams = [self v2_encryptParams:@{@"appId":self.appId,
                                                             @"pointVersion":self.payPointVersion,
                                                             @"channelNo":self.channelNo}];
    [[QBPaymentHttpClient plainRequestClient] POST:[self absoluteURLStringWithURLPath:kQBPayPointsURL forTest:self.useTestServer]
                                  withParams:encryptedParams
                           completionHandler:^(id obj, NSError *error)
    {
        NSDictionary *resp = [self v2_decryptResponse:obj];
        if ([resp[@"code"] unsignedIntegerValue] == 100 && [resp[@"data"] isKindOfClass:[NSDictionary class]]) {
            success(NO, resp[@"data"]);
        } else {
            [[QBPaymentHttpClient sharedClient] GET:[NSString stringWithFormat:kQBPayPointsStandbyURL, self.appId] withParams:nil completionHandler:^(id obj, NSError *error) {
                if (error) {
                    NSArray *cachedResults = [[NSArray alloc] initWithContentsOfFile:self.payPointsCachedPath];
                    if (cachedResults.count > 0) {
                        success(YES, cachedResults);
                    } else {
                        QBSafelyCallBlock(completionHandler, NO, nil);
                    }
                } else {
                    NSDictionary *standbyResponse = [self v2_decryptResponse:obj];
                    if ([standbyResponse[@"code"] unsignedIntegerValue] == 100 && [standbyResponse[@"data"] isKindOfClass:[NSArray class]]) {
                        success(NO, standbyResponse[@"data"]);
                    } else {
                        QBSafelyCallBlock(completionHandler, NO, nil);
                    }
                }
            }];
            
        }
    }];
}

- (void)request_queryOrders:(NSString *)orders
      withCompletionHandler:(QBCompletionHandler)completionHandler
{
    if (QBP_STRING_IS_EMPTY(orders)) {
        QBSafelyCallBlock(completionHandler, NO, nil);
        return ;
    }
    
    NSDictionary *encryptedParams = [self encryptParams:@{@"orderId":orders}];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", kQBQueryOrderServer, kQBQueryOrderURL];
    
    [[QBPaymentHttpClient sharedClient] POST:urlString
                                  withParams:encryptedParams
                           completionHandler:^(id obj, NSError *error)
    {
        NSString *response = [self decryptResponse:obj];
        
        QBLog(@"Manual activation response : %@", response);
        QBSafelyCallBlock(completionHandler, response.length>0, response);
    }];
}

- (NSDictionary *)encryptParams:(NSDictionary *)params {

    // Signing: appId, key, imsi, channelNo, pV
    NSArray *signingValues = @[self.appId, kQBPaymentNetworkingSignKey, @"999999999999999", self.channelNo, self.pv];
    
    NSMutableString *sign = [[NSMutableString alloc] init];
    [signingValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sign appendFormat:@"%@", obj];
    }];
    [sign appendString:@"null"];
    
    __block NSMutableString *paramString = [NSMutableString string];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isKindOfClass:[NSString class]]) {
            NSString *keyValueString = [NSString stringWithFormat:@"&%@=%@", key, obj];
            [paramString appendString:keyValueString];
        }
    }];
    
    NSString *signedParams = [NSString stringWithFormat:@"sign=%@%@", sign.md5, paramString ?: @""];
    NSString *encryptedDataString = [signedParams encryptedStringWithPassword:[kQBPaymentCryptPassword.md5 substringToIndex:16]];
    return @{@"data":encryptedDataString, @"appId":self.appId};
}

- (NSDictionary *)v2_encryptParams:(id)params {

    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSString *paramString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (paramString.length == 0) {
        return nil;
    }
    
    NSString *encryption = [paramString encryptedStringWithPassword:[kQBPaymentCryptPassword.md5 substringToIndex:16]];
    if (encryption.length == 0) {
        return nil;
    }
    
    return @{@"data":encryption};
}

- (id)decryptResponse:(id)response {
    if (![response isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSDictionary *originalResponse = (NSDictionary *)response;
    NSArray *keys = [originalResponse objectForKey:@"key"];
    NSString *dataString = [originalResponse objectForKey:@"data"];
    if (!keys || !dataString) {
        return nil;
    }
    
    NSString *decryptedString = [dataString decryptedStringWithKeys:keys];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:[decryptedString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    if (jsonObject == nil) {
        jsonObject = decryptedString;
    }
    return jsonObject;
}

- (id)v2_decryptResponse:(id)response {
    NSString *respString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    if (respString.length == 0) {
        return nil;
    }
    
    NSString *decryptedString = [respString decryptedStringWithPassword:[kQBPaymentCryptPassword.md5 substringToIndex:16]];
    if (decryptedString.length == 0) {
        return nil;
    }
    
    id respObject = [NSJSONSerialization JSONObjectWithData:[decryptedString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    return respObject;
}
@end
