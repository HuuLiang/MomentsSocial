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
#import "MSTabBarController.h"
#import "MSNavigationController.h"

@implementation MSContactModel

+ (NSArray *)reloadAllContactInfos {
    return [MSContactModel findByCriteria:[NSString stringWithFormat:@"order by unreadCount desc,msgTime desc"]];
}

+ (void)deletePastContactInfo {
    [[MSContactModel findAll] enumerateObjectsUsingBlock:^(MSContactModel * _Nonnull contact, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![[NSDate dateWithTimeIntervalSince1970:contact.msgTime] isToday]) {
            contact.msgTime = 0;
            contact.msgContent = @"";
            contact.unreadCount = 0;
            [contact saveOrUpdate];
        }
    }];
}

+ (BOOL)addContactInfoWithReplyMsg:(MSAutoReplyMsg *)replyMsg {
    
    if ([replyMsg.nickName isEqualToString:[MSUtil currentNickName]] ) {
        
    }
    
    if ([[NSDate date] timeIntervalSince1970] - replyMsg.msgTime < 10) {
        if (replyMsg.msgType == MSMessageTypeFaceTime) {
            [MSFaceTimeView showWithReplyMsgInfo:replyMsg];
        } else {
            [MSContactView showWithReplyMsgInfo:replyMsg];
        }
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
        contactInfo.msgContent = replyMsg.msgContent;
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
    
    BOOL saveSuccess = [contactInfo saveOrUpdate];
    if (saveSuccess) {
        [self refreshBadgeNumber];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMSPostContactInfoNotification object:contactInfo];
    }
    
    return saveSuccess;
}

+ (void)refreshBadgeNumber {
    dispatch_async(dispatch_queue_create(0, 0), ^{
        NSInteger allUnReadCount = [MSContactModel findSumsWithProperty:@"unreadCount"];
        MSTabBarController *tabBarVC = (MSTabBarController *)[MSUtil rootViewControlelr];
        if (![tabBarVC isKindOfClass:[MSTabBarController class]]) {
            return ;
        }
        MSNavigationController *contactNav = [tabBarVC.viewControllers objectAtIndex:2];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].applicationIconBadgeNumber = allUnReadCount;
            if (allUnReadCount > 0) {
                if (allUnReadCount < 100) {
                    contactNav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", (unsigned long)allUnReadCount];
                } else {
                    contactNav.tabBarItem.badgeValue = @"99+";
                }
            } else {
                contactNav.tabBarItem.badgeValue = nil;
            }
        });
    });
}

@end
