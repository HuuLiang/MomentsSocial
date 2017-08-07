//
//  MSSystemConfigModel.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/3.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "QBDataResponse.h"

@interface MSConfigInfo : NSObject
@property (nonatomic) NSInteger PUSH_RATE;
@property (nonatomic) NSString *SPREAD_IMG;
@end

@interface MSSystemConfigModel : QBDataResponse

+ (instancetype)defaultConfig;

@property (nonatomic) MSConfigInfo *config;

@end
