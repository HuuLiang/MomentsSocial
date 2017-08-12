//
//  MSContactModel.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "JKDBModel.h"

@class MSAutoReplyMsg;

@interface MSContactModel : JKDBModel

@property (nonatomic) NSInteger userId;

@property (nonatomic) NSString *portraitUrl;

@property (nonatomic) NSString *nickName;

@property (nonatomic) NSString *msgContent;

@property (nonatomic) MSMessageType msgType;

@property (nonatomic) NSTimeInterval msgTime;

@property (nonatomic) NSInteger unreadCount;

+ (NSArray *)reloadAllContactInfos;

+ (void)refreshBadgeNumber;

+ (void)deletePastContactInfo;

+ (BOOL)addContactInfoWithReplyMsg:(MSAutoReplyMsg *)replyMsg;

@end
