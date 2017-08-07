//
//  MSDiscoverModel.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/7.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "QBDataResponse.h"

@interface MSFindInfo : NSObject
@property (nonatomic) NSString *findImg;
@property (nonatomic) NSInteger funType;
@property (nonatomic) NSString *findSubtitle;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *findDesc;
@end

@interface MSDiscoverModel : QBDataResponse
@property (nonatomic) NSArray <MSFindInfo *> *finds;
@end
