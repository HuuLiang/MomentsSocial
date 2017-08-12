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

+ (NSArray *)reloadAllContactInfos {
    return [MSContactModel findByCriteria:[NSString stringWithFormat:@"order by unreadCount desc,msgTime desc"]];
}

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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMSPostContactInfoNotification object:contactInfo];
    
    return [contactInfo saveOrUpdate];
}

//+ (BOOL)addContactInfoUserId:(NSInteger)userId nickName:(NSString *)nickName portraitUrl:(NSString *)portraitUrl {
//    MSContactModel *contactInfo = [MSContactModel findFirstByCriteria:[NSString stringWithFormat:@"where userId=%ld",(long)userId]];
//    if (!contactInfo) {
//        contactInfo = [[MSContactModel alloc] init];
//        contactInfo.unreadCount = 0;
//    }
//    contactInfo.userId = userId;
//    contactInfo.nickName = nickName;
//    contactInfo.portraitUrl = portraitUrl;
//    contactInfo.msgTime = [[NSDate date] timeIntervalSince1970];
//    contactInfo.msgType = MSMessageTypeText;
//    contactInfo.msgContent = @"我对你很有感觉呦😊";
//    contactInfo.unreadCount += 1;
//    [[NSNotificationCenter defaultCenter] postNotificationName:kMSPostContactInfoNotification object:contactInfo];
//    return [contactInfo saveOrUpdate];
//}

+ (void)refreshBadgeNumber {
    NSInteger allUnReadCount = [MSContactModel findSumsWithProperty:@"unreadCount"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMSPostUnReadCountNotification object:@(allUnReadCount)];
}

@end
