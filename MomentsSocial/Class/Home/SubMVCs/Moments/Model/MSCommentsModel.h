//
//  MSCommentsModel.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/7.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "QBDataResponse.h"

@class MSMomentCommentsInfo;

@interface MSCommentsModel : QBDataResponse

@property (nonatomic) NSArray <MSMomentCommentsInfo *> *comments;

@end
