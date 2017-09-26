//
//  MSSystemConfigModel.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/3.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "QBDataResponse.h"

@interface MSPayInfo : NSObject
@property (nonatomic) NSNumber * payPointId;
@property (nonatomic) NSString *title;
@property (nonatomic) NSInteger price;
@property (nonatomic) NSInteger days;
@property (nonatomic) NSString *subTitle;
@property (nonatomic) NSString *desc;
@end

@interface MSConfigInfo : NSObject

@property (nonatomic) NSInteger     PUSH_RATE;
@property (nonatomic) NSInteger     PUSH_COUNT;
@property (nonatomic) NSInteger     PUSH_TIME;
@property (nonatomic) NSString      *SPREAD_IMG;
@property (nonatomic) NSString      *CONTACT_NAME;
@property (nonatomic) NSString      *CONTACT_SCHEME;
@property (nonatomic) NSInteger     PAY_AMOUNT_1;
@property (nonatomic) NSInteger     PAY_AMOUNT_2;
@property (nonatomic) NSString     *PAY_VIP_1_1;
@property (nonatomic) NSString     *PAY_VIP_1_2;
@property (nonatomic) NSString     *PAY_VIP_2_1;
@property (nonatomic) NSString     *PAY_VIP_2_2;
@property (nonatomic) NSString     *KFC_IMG;
@property (nonatomic) NSString     *OPEN_IMG;
@end

@interface MSSystemConfigModel : QBDataResponse

+ (instancetype)defaultConfig;

- (void)configPayInfoWithConfig:(MSConfigInfo *)config;

@property (nonatomic) MSConfigInfo *config;

@property (nonatomic) MSPayInfo     *PAY_VIP_1_1;
@property (nonatomic) MSPayInfo     *PAY_VIP_1_2;
@property (nonatomic) MSPayInfo     *PAY_VIP_2_1;
@property (nonatomic) MSPayInfo     *PAY_VIP_2_2;

@end

FOUNDATION_EXTERN NSString *const kMSPayInfoPAY_VIP_1_1KeyName;
FOUNDATION_EXTERN NSString *const kMSPayInfoPAY_VIP_1_2KeyName;
FOUNDATION_EXTERN NSString *const kMSPayInfoPAY_VIP_2_1KeyName;
FOUNDATION_EXTERN NSString *const kMSPayInfoPAY_VIP_2_2KeyName;

