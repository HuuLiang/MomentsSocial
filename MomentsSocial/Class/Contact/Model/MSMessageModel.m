//
//  MSMessageModel.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMessageModel.h"
#import "MSAutoReplyMessageManager.h"
#import "MSContactModel.h"

@implementation MSMessageModel

+ (NSArray<MSMessageModel *> *)allMessagesWithUserId:(NSString *)userId {
    NSArray  <MSMessageModel *> * allMsgs = [self findByCriteria:[NSString stringWithFormat:@"WHERE sendUserId=\'%@\' or receiveUserId=\'%@\'",userId,userId]];
    return allMsgs;
}

+ (void)deletePastMessageInfo {
    [[MSMessageModel findAll] enumerateObjectsUsingBlock:^(MSMessageModel *  _Nonnull messageModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![[NSDate dateWithTimeIntervalSince1970:messageModel.msgTime] isToday]) {
            [messageModel deleteObject];
        }
    }];
}

+ (BOOL)addMessageInfoWithReplyMsg:(MSAutoReplyMsg *)replyMsg {
    MSMessageModel *messageModel = [[MSMessageModel alloc] init];
    messageModel.sendUserId = [NSString stringWithFormat:@"%ld",(long)replyMsg.userId];
    messageModel.receiveUserId = [NSString stringWithFormat:@"%ld",(long)[MSUtil currentUserId]];
    messageModel.nickName = replyMsg.nickName;
    messageModel.portraitUrl = replyMsg.portraitUrl;
    messageModel.msgTime = replyMsg.msgTime;
    messageModel.msgType = replyMsg.msgType;
    if (messageModel.msgType == MSMessageTypeText) {
        messageModel.readDone = NO;
        messageModel.msgContent = replyMsg.msgContent;
    } else if (messageModel.msgType == MSMessageTypePhoto) {
        messageModel.imgUrl = replyMsg.imgUrl;
    } else if (messageModel.msgType == MSMessageTypeVoice) {
        messageModel.voiceUrl = replyMsg.voiceUrl;
        messageModel.voiceDuration = replyMsg.voiceDuration;
    } else if (messageModel.msgType == MSMessageTypeVideo) {
        messageModel.videoImgUrl = replyMsg.videoImgUrl;
        messageModel.videoUrl = replyMsg.videoUrl;
    } else if (messageModel.msgType == MSMessageTypeFaceTime) {
        messageModel.msgContent = replyMsg.msgContent;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMSPostMessageInfoNotification object:messageModel];
    
    return [messageModel saveOrUpdate];
}

+ (BOOL)addMessageInfoWithUserId:(NSInteger)userId nickName:(NSString *)nickName portraitUrl:(NSString *)portraitUrl {
    MSMessageModel *messageModel = [[MSMessageModel alloc] init];
    messageModel.sendUserId = [NSString stringWithFormat:@"%ld",(long)[MSUtil currentUserId]];
    messageModel.receiveUserId = [NSString stringWithFormat:@"%ld",(long)userId];
    messageModel.nickName = nickName;
    messageModel.portraitUrl = portraitUrl;
    messageModel.msgTime = [[NSDate date] timeIntervalSince1970];
    messageModel.msgType = MSMessageTypeText;
    messageModel.msgContent = @"我对你很有感觉呦😊";
    messageModel.readDone = NO;
    
    [self postMessageInfoToContact:messageModel];
    [[MSAutoReplyMessageManager manager] fetchOneUserMessageInfoWithUserId:messageModel.receiveUserId];
    return [messageModel save];
}

+ (void)postMessageInfoToContact:(MSMessageModel *)msgModel {
    NSInteger userId = [msgModel.sendUserId integerValue] == [MSUtil currentUserId] ? [msgModel.receiveUserId integerValue] : [msgModel.sendUserId integerValue];
    MSContactModel *contactInfo = [MSContactModel findFirstByCriteria:[NSString stringWithFormat:@"where userId=%ld",(long)userId]];
    if (!contactInfo) {
        contactInfo = [[MSContactModel alloc] init];
    } else {
        if (contactInfo.msgTime == msgModel.msgTime) {
            return;
        }
    }
    contactInfo.userId = userId;
    contactInfo.nickName = msgModel.nickName;
    contactInfo.portraitUrl = msgModel.portraitUrl;
    contactInfo.msgType = msgModel.msgType;
    contactInfo.msgTime = msgModel.msgTime;
    contactInfo.unreadCount = 0;
    contactInfo.msgContent = msgModel.msgContent;
    [contactInfo saveOrUpdate];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMSPostContactInfoNotification object:contactInfo];

}

+ (MSMessageModel *)vipNoticeMessage {
    MSMessageModel *messageModel = [[MSMessageModel alloc] init];
    messageModel.msgType = MSMessageTypeVipNotice;
    return messageModel;
}

+ (void)postMessageToServer:(MSMessageModel *)msgModel {
    [[MSAutoReplyMessageManager manager] fetchKeywordReplyMsgWithMsgInfo:msgModel];
    [[MSAutoReplyMessageManager manager] fetchAIReplyMsgWithMsgInfo:msgModel];
}

@end
