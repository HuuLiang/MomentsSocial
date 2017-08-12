//
//  QBOrderInfo.h
//  Pods
//
//  Created by Sean Yue on 2016/12/7.
//
//

#import <Foundation/Foundation.h>
#import "QBPaymentDefines.h"

@interface QBOrderInfo : NSObject

@property (nonatomic) NSString *orderId;
@property (nonatomic) NSUInteger orderPrice;  //以分为单位
@property (nonatomic) NSString *orderDescription;
@property (nonatomic) QBPaymentType payType;
@property (nonatomic) NSUInteger maxDiscount;  // 最大减免金额，单位：角

@property (nonatomic) NSString *createTime;
@property (nonatomic) NSString *userId;
@property (nonatomic) NSUInteger currentPayPointType;
@property (nonatomic) NSUInteger targetPayPointType;
@property (nonatomic) NSString *reservedData;

@end
