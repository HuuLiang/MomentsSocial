//
//  MSOnlineManager.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/10.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,MSUserType) {
    MSUserTypeOldPush,
    MSUserTypeNewPush,
    MSUserTypeCircle
};

@interface MSOnlineInfo : JKDBModel
@property (nonatomic) NSInteger userId;
@property (nonatomic) BOOL online;
@property (nonatomic) MSUserType type;
@property (nonatomic) NSTimeInterval changeTime;
@end

@interface MSOnlineManager : NSObject

@property (nonatomic) BOOL replyLastPushUser;

+ (instancetype)manager;


/**
 向在线管理器增加用户

 @param userId 用户id
 @param type 用户类型
 @param handler 返回该用户是否在线 (如需要 可选用)
 */
- (void)addUser:(NSInteger)userId type:(MSUserType)type handler:(void(^)(BOOL online))handler;



/**
 重置所有的在线状态
 */
- (void)resetAllOnlineInfo;


/**
 重置所有的推送机器人在线状态
 */
- (void)setAllPushUserOffline;


/**
 检测用户是否在线

 @param userId 用户id
 @return 返回是否在线的结果
 */
- (BOOL)onlineWithUserId:(NSInteger)userId;

@end
