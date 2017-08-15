//
//  MSActivityModel.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "QBDataResponse.h"

@interface MSActivityModel : QBDataResponse
@property (nonatomic) NSString *uuid;
@property (nonatomic) NSInteger userId;
@property (nonatomic) NSString *portraitUrl;
@property (nonatomic) NSString *nickName;
@end
