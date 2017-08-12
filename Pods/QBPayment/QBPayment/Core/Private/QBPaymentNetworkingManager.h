//
//  QBPaymentNetworkingManager.h
//  Pods
//
//  Created by Sean Yue on 2017/6/2.
//
//

#import <Foundation/Foundation.h>
#import "QBPaymentDefines.h"

@interface QBPaymentNetworkingManager : NSObject

@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *channelNo;
@property (nonatomic) NSNumber *pv;
@property (nonatomic) NSNumber *payPointVersion;

@property (nonatomic) BOOL useTestServer; //Only for payment configuration and paypoints

QBDeclareSingletonMethod(defaultManager)

- (void)request_commitPaymentInfo:(QBPaymentInfo *)paymentInfo withCompletionHandler:(QBCompletionHandler)completionHandler;
- (void)request_fetchPaymentConfigurationWithCompletionHandler:(QBCompletionHandler)completionHandler;
- (void)request_fetchPayPointsWithCompletionHandler:(QBCompletionHandler)completionHandler;

- (void)request_queryOrders:(NSString *)orders withCompletionHandler:(QBCompletionHandler)completionHandler;

@end
