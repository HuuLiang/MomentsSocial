//
//  MSCircleModel.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/3.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "QBDataResponse.h"

@interface MSCircleInfo : NSObject

@property (nonatomic) NSString *circleImg;

@property (nonatomic) NSInteger number;

@property (nonatomic) NSString *circleDesc;

@property (nonatomic) NSString *name;

@property (nonatomic) NSInteger circleId;

@property (nonatomic) MSLevel vipLv;

@end

@interface MSCircleModel : QBDataResponse
@property (nonatomic) NSArray <MSCircleInfo *> *circle;
@property (nonatomic) NSArray <MSCircleInfo *> *hotCircle;
@end
