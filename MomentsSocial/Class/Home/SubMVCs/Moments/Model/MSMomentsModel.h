//
//  MSMomentsModel.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/31.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "QBDataResponse.h"

@interface MSMomentModel : NSObject
@property (nonatomic) NSString *content;
@property (nonatomic) NSInteger momentsType;
@property (nonatomic) NSInteger photosCount;
@property (nonatomic) NSArray *dataSource;
@property (nonatomic) NSString *nick1;
@property (nonatomic) NSString *nick2;
@property (nonatomic) NSString *comment1;
@property (nonatomic) NSString *comment2;
@end


@interface MSMomentsModel : QBDataResponse
@property (nonatomic) NSArray <MSMomentModel *>* moments;
@end
