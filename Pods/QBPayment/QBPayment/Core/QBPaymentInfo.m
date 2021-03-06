//
//  QBPaymentInfo.m
//  QBPayment
//
//  Created by Sean Yue on 15/12/17.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "QBPaymentInfo.h"
#import "QBDefines.h"
#import "NSMutableDictionary+SafeCoding.h"
#import "NSString+md5.h"
#import "QBOrderInfo.h"
#import "QBContentInfo.h"
#import "QBPayPoint.h"
#import <NSObject+BaseRepresentation.h>

static NSString *const kPaymentInfoKeyName = @"qbpayment_paymentinfo_keyname";

static NSString *const kPaymentInfoPaymentIdKeyName = @"qbpayment_paymentinfo_paymentid_keyname";
static NSString *const kPaymentInfoOrderIdKeyName = @"qbpayment_paymentinfo_orderid_keyname";
static NSString *const kPaymentInfoOrderPriceKeyName = @"qbpayment_paymentinfo_orderprice_keyname";
static NSString *const kPaymentInfoOrderDescriptionKeyName = @"qbpayment_paymentinfo_orderdescription_keyname";
static NSString *const kPaymentInfoContentIdKeyName = @"qbpayment_paymentinfo_contentid_keyname";
static NSString *const kPaymentInfoContentTypeKeyName = @"qbpayment_paymentinfo_contenttype_keyname";
static NSString *const kPaymentInfoContentLocationKeyName = @"qbpayment_paymentinfo_contentlocation_keyname";
static NSString *const kPaymentInfoColumnIdKeyName = @"qbpayment_paymentinfo_columnid_keyname";
static NSString *const kPaymentInfoColumnTypeKeyName = @"qbpayment_paymentinfo_columntype_keyname";
static NSString *const kPaymentInfoPayPointTypeKeyName = @"qbpayment_paymentinfo_paypointtype_keyname";
static NSString *const kPaymentInfoCurrentPayPointTypeKeyName = @"qbpayment_paymentinfo_currentpaypointtype_keyname";
static NSString *const kPaymentInfoTargetPayPointTypeKeyName = @"qbpayment_paymentinfo_targetpaypointtype_keyname";
static NSString *const kPaymentInfoPluginTypeKeyName = @"qbpayment_paymentinfo_plugintype_keyname";
static NSString *const kPaymentInfoPaymentTypeKeyName = @"qbpayment_paymentinfo_paymenttype_keyname";
static NSString *const kPaymentInfoPaymentResultKeyName = @"qbpayment_paymentinfo_paymentresult_keyname";
static NSString *const kPaymentInfoPaymentStatusKeyName = @"qbpayment_paymentinfo_paymentstatus_keyname";
static NSString *const kPaymentInfoPaymentTimeKeyName = @"qbpayment_paymentinfo_paymenttime_keyname";
static NSString *const kPaymentInfoPaymentReservedDataKeyName = @"qbpayment_paymentinfo_paymentreserveddata_keyname";
static NSString *const kPaymentInfoPayPointKeyName = @"qbpayment_paymentinfo_paypoint_keyname";
static NSString *const kPaymentInfoUserIdKeyName = @"qbpayment_paymentinfo_userid_keyname";

static NSString *const kPaymentInfoVersionKeyName = @"qbpayment_paymentinfo_version_keyname";

@interface QBPaymentInfo ()
@property (nonatomic) NSString *paymentId;
@end

@implementation QBPaymentInfo

- (NSString *)paymentId {
    if (_paymentId) {
        return _paymentId;
    }
    
    _paymentId = [NSUUID UUID].UUIDString.md5;
    if (!_paymentId) {
        _paymentId = @([[NSDate date] timeIntervalSince1970]).stringValue.md5;
    }
    return _paymentId;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _paymentResult = QBPayResultUnknown;
        _paymentStatus = QBPayStatusUnknown;
        _version = @0.1;
    }
    return self;
}

- (instancetype)initWithOrderInfo:(QBOrderInfo *)orderInfo contentInfo:(QBContentInfo *)contentInfo {
    self = [self init];
    if (self) {
        
        _orderId = orderInfo.orderId;
        _orderPrice = orderInfo.orderPrice;
        _orderDescription = orderInfo.orderDescription;
        _paymentType = orderInfo.payType;
        _paymentTime = orderInfo.createTime;
        _reservedData = orderInfo.reservedData;
        _payPointType = orderInfo.targetPayPointType;
        _currentPayPointType = orderInfo.currentPayPointType;
        _targetPayPointType = orderInfo.targetPayPointType;
        _userId = orderInfo.userId;
        
        _contentId = contentInfo.contentId;
        _contentType = contentInfo.contentType;
        _contentLocation = contentInfo.contentLocation;
        _columnId = contentInfo.columnId;
        _columnType = contentInfo.columnType;
    }
    return self;
}

- (instancetype)initWithOrderInfo:(QBOrderInfo *)orderInfo contentInfo:(QBContentInfo *)contentInfo payPoint:(QBPayPoint *)payPoint {
    self = [self initWithOrderInfo:orderInfo contentInfo:contentInfo];
    if (self) {
        _payPoint = payPoint;
    }
    return self;
}

+ (instancetype)paymentInfoFromDictionary:(NSDictionary *)payment {
    QBPaymentInfo *paymentInfo = [[self alloc] init];
    paymentInfo.paymentId = payment[kPaymentInfoPaymentIdKeyName];
    paymentInfo.orderId = payment[kPaymentInfoOrderIdKeyName];
    paymentInfo.orderPrice = [payment[kPaymentInfoOrderPriceKeyName] unsignedIntegerValue];
    paymentInfo.orderDescription = payment[kPaymentInfoOrderDescriptionKeyName];
    paymentInfo.contentId = payment[kPaymentInfoContentIdKeyName];
    paymentInfo.contentType = payment[kPaymentInfoContentTypeKeyName];
    paymentInfo.contentLocation = payment[kPaymentInfoContentLocationKeyName];
    paymentInfo.columnId = payment[kPaymentInfoColumnIdKeyName];
    paymentInfo.columnType = payment[kPaymentInfoColumnTypeKeyName];
    paymentInfo.payPointType = [payment[kPaymentInfoPayPointTypeKeyName] unsignedIntegerValue];
    paymentInfo.currentPayPointType = [payment[kPaymentInfoCurrentPayPointTypeKeyName] unsignedIntegerValue];
    paymentInfo.targetPayPointType = [payment[kPaymentInfoTargetPayPointTypeKeyName] unsignedIntegerValue];
    paymentInfo.pluginType = [payment[kPaymentInfoPluginTypeKeyName] unsignedIntegerValue];
    paymentInfo.paymentType = [payment[kPaymentInfoPaymentTypeKeyName] unsignedIntegerValue];
    paymentInfo.paymentResult = [payment[kPaymentInfoPaymentResultKeyName] unsignedIntegerValue];
    paymentInfo.paymentStatus = [payment[kPaymentInfoPaymentStatusKeyName] unsignedIntegerValue];
    paymentInfo.paymentTime = payment[kPaymentInfoPaymentTimeKeyName];
    paymentInfo.reservedData = payment[kPaymentInfoPaymentReservedDataKeyName];
    paymentInfo.userId = payment[kPaymentInfoUserIdKeyName];
    paymentInfo.version = payment[kPaymentInfoVersionKeyName];
    paymentInfo.payPoint = [QBPayPoint objectFromDictionary:payment[kPaymentInfoPayPointKeyName]];
    return paymentInfo;
}

- (NSDictionary *)dictionaryFromCurrentPaymentInfo {
    NSMutableDictionary *payment = [NSMutableDictionary dictionary];
    [payment safelySetObject:self.paymentId forKey:kPaymentInfoPaymentIdKeyName];
    [payment safelySetObject:self.orderId forKey:kPaymentInfoOrderIdKeyName];
    [payment safelySetObject:@(self.orderPrice) forKey:kPaymentInfoOrderPriceKeyName];
    [payment safelySetObject:self.orderDescription forKey:kPaymentInfoOrderDescriptionKeyName];
    [payment safelySetObject:self.contentId forKey:kPaymentInfoContentIdKeyName];
    [payment safelySetObject:self.contentType forKey:kPaymentInfoContentTypeKeyName];
    [payment safelySetObject:self.contentLocation forKey:kPaymentInfoContentLocationKeyName];
    [payment safelySetObject:self.columnId forKey:kPaymentInfoColumnIdKeyName];
    [payment safelySetObject:self.columnType forKey:kPaymentInfoColumnTypeKeyName];
    [payment safelySetObject:@(self.payPointType) forKey:kPaymentInfoPayPointTypeKeyName];
    [payment safelySetObject:@(self.currentPayPointType) forKey:kPaymentInfoCurrentPayPointTypeKeyName];
    [payment safelySetObject:@(self.targetPayPointType) forKey:kPaymentInfoTargetPayPointTypeKeyName];
    [payment safelySetObject:@(self.pluginType) forKey:kPaymentInfoPluginTypeKeyName];
    [payment safelySetObject:@(self.paymentType) forKey:kPaymentInfoPaymentTypeKeyName];
    [payment safelySetObject:@(self.paymentResult) forKey:kPaymentInfoPaymentResultKeyName];
    [payment safelySetObject:@(self.paymentStatus) forKey:kPaymentInfoPaymentStatusKeyName];
    [payment safelySetObject:self.paymentTime forKey:kPaymentInfoPaymentTimeKeyName];
    [payment safelySetObject:self.reservedData forKey:kPaymentInfoPaymentReservedDataKeyName];
    [payment safelySetObject:self.userId forKey:kPaymentInfoUserIdKeyName];
    [payment safelySetObject:self.version forKey:kPaymentInfoVersionKeyName];
    [payment safelySetObject:[self.payPoint dictionaryRepresentation] forKey:kPaymentInfoPayPointKeyName];
    return payment;
}

+ (NSArray<QBPaymentInfo *> *)allPaymentInfos {
    NSArray<NSDictionary *> *paymentInfoArr = [[NSUserDefaults standardUserDefaults] objectForKey:kPaymentInfoKeyName];
    
    NSMutableArray *paymentInfos = [NSMutableArray array];
    [paymentInfoArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        QBPaymentInfo *paymentInfo = [QBPaymentInfo paymentInfoFromDictionary:obj];
        [paymentInfos addObject:paymentInfo];
    }];
    return paymentInfos.count > 0 ? paymentInfos : nil;
}

- (void)save {
    NSArray *paymentInfos = [[NSUserDefaults standardUserDefaults] objectForKey:kPaymentInfoKeyName];
    
    NSMutableArray *paymentInfosM = [paymentInfos mutableCopy];
    if (!paymentInfosM) {
        paymentInfosM = [NSMutableArray array];
    }
    
    NSUInteger index = [paymentInfos indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *paymentId = ((NSDictionary *)obj)[kPaymentInfoPaymentIdKeyName];
        if ([paymentId isEqualToString:self.paymentId]) {
            return YES;
        }
        return NO;
    }];
    NSDictionary *payment = index != NSNotFound ? [paymentInfos objectAtIndex:index] : nil;
    
    if (payment) {
        [paymentInfosM removeObject:payment];
    }
    
    payment = [self dictionaryFromCurrentPaymentInfo];
    [paymentInfosM addObject:payment];
    
    [[NSUserDefaults standardUserDefaults] setObject:paymentInfosM forKey:kPaymentInfoKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    QBLog(@"Save payment info: %@", payment);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", [self dictionaryFromCurrentPaymentInfo]];
}
@end
