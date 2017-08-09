//
//  MSSystemConfigModel.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/3.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "QBDataResponse.h"

@interface MSConfigInfo : NSObject

//CONTACT_NAME
//CONTACT_SCHEME
//PAY_AMOUNT_1
//PAY_AMOUNT_2
//PUSH_COUNT
//PUSH_RATE
//SPREAD_IMG

@property (nonatomic) NSInteger     PUSH_RATE;
@property (nonatomic) NSInteger     PUSH_COUNT;
@property (nonatomic) NSString      *SPREAD_IMG;
@property (nonatomic) NSString      *CONTACT_NAME;
@property (nonatomic) NSString      *CONTACT_SCHEME;
@property (nonatomic) NSInteger     PAY_AMOUNT_1;
@property (nonatomic) NSInteger     PAY_AMOUNT_2;
@end

@interface MSSystemConfigModel : QBDataResponse

+ (instancetype)defaultConfig;

@property (nonatomic) MSConfigInfo *config;

@end
