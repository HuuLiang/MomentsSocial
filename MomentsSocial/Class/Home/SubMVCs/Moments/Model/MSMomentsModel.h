//
//  MSMomentsModel.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/31.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "QBDataResponse.h"

@interface MSMomentCommentsInfo : NSObject
@property (nonatomic) NSString *content;
@property (nonatomic) NSString *nickName;
@end

@interface MSMomentModel : JKDBModel
@property (nonatomic) NSInteger moodId;
@property (nonatomic) NSInteger userId;
@property (nonatomic) NSInteger commentCount;
@property (nonatomic) NSArray <MSMomentCommentsInfo *> *comments;
@property (nonatomic) NSInteger likesNumber;
@property (nonatomic) NSString *portraitUrl;
@property (nonatomic) NSArray *moodUrl;
@property (nonatomic) NSString *text;
@property (nonatomic) NSInteger type;
@property (nonatomic) NSString *nickName;
@property (nonatomic) NSString *videoImg;
@property (nonatomic) NSString *videoUrl;

@property (nonatomic) BOOL greeted;
@property (nonatomic) BOOL loved;
@property (nonatomic) NSString *location;

- (BOOL)isGreeted;
- (void)setUserGreeted:(BOOL)greeted;

- (BOOL)isLoved;
@end


@interface MSMomentsModel : QBDataResponse
@property (nonatomic) NSArray <MSMomentModel *> * mood;
@end
