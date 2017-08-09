//
//  MSContactModel.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSContactModel.h"
#import "MSAutoReplyMessageManager.h"
#import "MSContactView.h"
#import "MSFaceTimeView.h"

@implementation MSContactModel

+ (void)deletePastContactInfo {
    [[MSContactModel findAll] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(MSContactModel * _Nonnull contact, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![[NSDate dateWithTimeIntervalSince1970:contact.msgTime] isToday]) {
            contact.msgTime = 0;
            contact.msgContent = @"";
            contact.unreadCount = 0;
            [contact saveOrUpdate];
        }
    }];
}

+ (BOOL)addContactInfoWithReplyMsg:(MSAutoReplyMsg *)replyMsg {
    
    if (replyMsg.msgType == MSMessageTypeFaceTime) {
        [MSFaceTimeView showWithReplyMsgInfo:replyMsg];
    } else {
        [MSContactView showWithReplyMsgInfo:replyMsg];
    }
    
    MSContactModel *contactInfo = [MSContactModel findFirstByCriteria:[NSString stringWithFormat:@"where userId=%ld",(long)replyMsg.userId]];
    if (!contactInfo) {
        contactInfo = [[MSContactModel alloc] init];
        contactInfo.unreadCount = 0;
    }
    contactInfo.userId = replyMsg.userId;
    contactInfo.nickName = replyMsg.nickName;
    contactInfo.portraitUrl = replyMsg.portraitUrl;
    contactInfo.msgTime = replyMsg.msgTime;
    contactInfo.msgType = replyMsg.msgType;
    if (replyMsg.msgType == MSMessageTypeText) {
        contactInfo.msgContent = contactInfo.msgContent;
    } else if (replyMsg.msgType == MSMessageTypePhoto) {
        contactInfo.msgContent = @"【图片】";
    } else if (replyMsg.msgType == MSMessageTypeVoice) {
        contactInfo.msgContent = @"【语音】";
    } else if (replyMsg.msgType == MSMessageTypeVideo) {
        contactInfo.msgContent = @"【视频】";
    } else if (replyMsg.msgType == MSMessageTypeFaceTime) {
        contactInfo.msgContent = @"【视频聊天邀请】";
    }
    contactInfo.unreadCount = contactInfo.unreadCount + 1;
    
    
    return [contactInfo saveOrUpdate];
}

@end
