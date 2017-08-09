//
//  MSMessageModel.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMessageModel.h"
#import "MSAutoReplyMessageManager.h"

@implementation MSMessageModel

+ (NSArray<MSMessageModel *> *)allMessagesWithUserId:(NSString *)userId {
    NSArray  <MSMessageModel *> * allMsgs = [self findByCriteria:[NSString stringWithFormat:@"WHERE sendUserId=\'%@\' or receiveUserId=\'%@\'",userId,userId]];
    return allMsgs;
}

+ (void)deletePastMessageInfo {
    [[MSMessageModel findAll] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(MSMessageModel *  _Nonnull messageModel, NSUInteger idx, BOOL * _Nonnull stop) {
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
    
    return [messageModel saveOrUpdate];
}

@end
