//
//  MSMessageModel.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MSAutoReplyMsg;

@interface MSMessageModel : JKDBModel
@property (nonatomic) NSString *sendUserId;
@property (nonatomic) NSString *receiveUserId;
@property (nonatomic) NSString *nickName;
@property (nonatomic) NSTimeInterval msgTime;
@property (nonatomic) NSString *portraitUrl;

@property (nonatomic) MSMessageType msgType;

@property (nonatomic) NSString *msgContent;
@property (nonatomic) BOOL readDone;

@property (nonatomic) NSString *imgUrl;

@property (nonatomic) NSString *voiceUrl;
@property (nonatomic) NSString *voiceDuration;

@property (nonatomic) NSString *videoUrl;
@property (nonatomic) NSString *videoImgUrl;

+ (NSArray <MSMessageModel *>*)allMessagesWithUserId:(NSString *)userId;

+ (void)deletePastMessageInfo;

+ (BOOL)addMessageInfoWithReplyMsg:(MSAutoReplyMsg *)replyMsg;

+ (void)postMessageInfoToContact:(MSMessageModel *)msgModel;

+ (BOOL)addMessageInfoWithUserId:(NSInteger)userId nickName:(NSString *)nickName portraitUrl:(NSString *)portraitUrl;

+ (MSMessageModel *)vipNoticeMessage;

+ (void)postMessageToServer:(MSMessageModel *)msgModel;

@end
