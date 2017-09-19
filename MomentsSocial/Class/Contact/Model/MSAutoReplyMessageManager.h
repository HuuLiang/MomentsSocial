//
//  MSAutoReplyMessageManager.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/9.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBDataResponse.h"

typedef NS_ENUM(NSInteger,MSReplyDataSourceType) {
    MSReplyDataSourceTypeAdd,
    MSReplyDataSourceTypeDel,
    MSReplyDataSourceTypeSort,
    MSReplyDataSourceTypeDelAll
};

@class MSMessageModel;

@interface MSAutoReplyMsg : JKDBModel
@property (nonatomic) NSInteger msgId;
@property (nonatomic) NSInteger userId;
@property (nonatomic) NSString *nickName;
@property (nonatomic) NSString *portraitUrl;
@property (nonatomic) NSTimeInterval msgTime;

@property (nonatomic) MSMessageType msgType;

@property (nonatomic) NSString *msgContent;

@property (nonatomic) NSString *imgUrl;

@property (nonatomic) NSString *voiceUrl;
@property (nonatomic) NSString *voiceDuration;

@property (nonatomic) NSString *videoUrl;
@property (nonatomic) NSString *videoImgUrl;

@property (nonatomic) BOOL replyed;

+ (void)deletePastAutoReplyMsgInfo;
+ (void)deleteAllAutoReplyMsgInfo;
@end


@interface MSAutoReplyOneResponse : QBDataResponse
@property (nonatomic) MSUserModel *user;
@end

@interface MSAutoReplyBatchResponse : QBDataResponse
@property (nonatomic) NSArray <MSUserModel *> *pushUser;
@end


@interface MSKeywordsReplyResponse : QBDataResponse
@property (nonatomic) MSUserMsgModel *message;
@end







@interface MSAutoReplyMessageManager : NSObject

+ (instancetype)manager;

- (void)startAutoReplyMsgEvent;

//- (void)fetchOneReplyUserInfo;

- (void)fetchOneUserMessageInfoWithUserId:(NSString *)userId;

- (void)fetchKeywordReplyMsgWithMsgInfo:(MSMessageModel *)messageModel;

- (void)fetchAIReplyMsgWithMsgInfo:(MSMessageModel *)messageModel;

@end

