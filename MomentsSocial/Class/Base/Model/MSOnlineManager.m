//
//  MSOnlineManager.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/10.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSOnlineManager.h"

static const NSTimeInterval kRollingChangeTimeInterval = 5;

static const NSTimeInterval PushUserNewPushTime = 60 * 5;
static const NSTimeInterval PushUserOldPushTime = 60 * 30;
static const NSTimeInterval CircleUserNormalTime = 60 * 30;

//static const NSTimeInterval PushUserNewPushTime = 60 * 2;
//static const NSTimeInterval PushUserOldPushTime = 60 * 2;
//static const NSTimeInterval CircleUserNormalTime = 60 * 2;


@implementation MSOnlineInfo

@end

@interface MSOnlineManager ()
//@property (nonatomic) dispatch_queue_t changeQueue;
@property (nonatomic) dispatch_queue_t sourceQueue;
@property (nonatomic) NSMutableArray <MSOnlineInfo *> *dataSource;
@end

@implementation MSOnlineManager
QBDefineLazyPropertyInitialization(NSMutableArray, dataSource)

+ (instancetype)manager {
    static MSOnlineManager *_onlineManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _onlineManager = [[MSOnlineManager alloc] init];
    });
    return _onlineManager;
}

- (dispatch_queue_t)sourceQueue {
    if (!_sourceQueue) {
        _sourceQueue = dispatch_queue_create("MomentsSocial_operateSource_queue", nil);
    }
    return _sourceQueue;
}

- (void)resetAllOnlineInfo {
    dispatch_async(self.sourceQueue, ^{
        [self.dataSource removeAllObjects];
        
        [self.dataSource addObjectsFromArray:[MSOnlineInfo findByCriteria:[NSString stringWithFormat:@"order by changeTime asc"]]];
        
        
        [self startOnlineChangedEvent];
    });
}

- (void)setAllPushUserOffline {
    [[MSOnlineInfo findAll] enumerateObjectsUsingBlock:^(MSOnlineInfo *  _Nonnull onlineInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        if (onlineInfo.type == MSUserTypeNewPush) {
            onlineInfo.type = MSUserTypeOldPush;
            NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
            BOOL userOnline = (arc4random()%2) == 1 ? YES : NO;
            onlineInfo.online = userOnline;
            onlineInfo.changeTime = currentTimeInterval + PushUserOldPushTime;
            if ([onlineInfo saveOrUpdate]) {
                [self addUser:onlineInfo];
            }
        }
    }];
}


/**
 新增一个用户到在线管理器里 老推送用户：每30分钟随机50%在线
                       新推送用户：最后一条消息发送完5分钟后离线  若全部离线 则每30分钟随机50%在线
                       圈子用户：每30分钟随机50%在线 如果与推送用户出现重复 则以推送用户当前状态为准

 @param userId 用户id
 @param type 用户类型 推送用户 圈子用户
 */
- (void)addUser:(NSInteger)userId type:(MSUserType)type handler:(void (^)(BOOL))handler {
    dispatch_async(self.sourceQueue, ^{
        NSInteger currentUserId = userId;
        
        MSUserType currentUserType;
        BOOL currentUserOnline;
        NSTimeInterval userChangeTime;
        
        NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
        BOOL userOnline = (arc4random()%2) == 1 ? YES : NO;
        
        MSOnlineInfo *info = [MSOnlineInfo findFirstByCriteria:[NSString stringWithFormat:@"where userId=%ld",(long)userId]];
        if (!info) {
            //如果用户不存在 类型即为传入的类型
            info = [[MSOnlineInfo alloc] init];
            
            currentUserType = type;
            
            if (currentUserType == MSUserTypeNewPush) {
                userChangeTime = currentTimeInterval + PushUserNewPushTime;
                currentUserOnline = YES;
            } else if (currentUserType == MSUserTypeOldPush) {
                userChangeTime = currentTimeInterval + PushUserOldPushTime;
                currentUserOnline = userOnline;
            } else {
                userChangeTime = currentTimeInterval + CircleUserNormalTime;
                currentUserOnline = userOnline;
            }
        } else {
            //如果用户存在 需要判断新传入的类型
            //  MSUserTypeOldPush 保持原来的类型
            //  MSUserTypeNewPush 更新到最新的推送用户类型
            //  MSUserTypeCircle 保持原来的类型
            if (type == MSUserTypeOldPush) {
                currentUserType = info.type;
            } else if (type == MSUserTypeNewPush) {
                currentUserType = MSUserTypeNewPush;
            } else {
                currentUserType = info.type;
            }
            
            //  根据当前用户类型设定更改时间
            //  MSUserTypeOldPush 保持原来的类型
            //  MSUserTypeNewPush 更新到最新的推送用户类型
            //  MSUserTypeCircle 保持原来的类型
            
            if (currentUserType == MSUserTypeNewPush) {
                userChangeTime = currentTimeInterval + PushUserNewPushTime;
                currentUserOnline = YES;
            } else if (currentUserType == MSUserTypeOldPush) {
                userChangeTime = info.changeTime;
                currentUserOnline = info.online;
            } else {
                userChangeTime = info.changeTime;
                currentUserOnline = info.online;
            }
        }
        
        info.userId = currentUserId;
        info.type = currentUserType;
        info.online = currentUserOnline;
        info.changeTime = userChangeTime;
        
        if ([info saveOrUpdate]) {
            [self addUser:info];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(info.online);
        });
    });
}

- (void)addUser:(MSOnlineInfo *)info {
    if (self.dataSource.count == 0) {
        [self.dataSource addObject:info];
        return ;
    }
    
    __block NSInteger insertIndex = NSNotFound;
    __block MSOnlineInfo *oldInfo;
    [self.dataSource enumerateObjectsUsingBlock:^(MSOnlineInfo * _Nonnull onlineInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        if (onlineInfo.userId == info.userId) {
            oldInfo = onlineInfo;
        }
        if (info.changeTime > onlineInfo.changeTime) {
            insertIndex = idx;
        }
    }];
    
    if (insertIndex == NSNotFound) {
        [self.dataSource addObject:info];
    } else {
        [self.dataSource insertObject:info atIndex:insertIndex];
    }
    if (oldInfo) {
        [self.dataSource removeObject:oldInfo];
    }
}

- (void)removeUser:(MSOnlineInfo *)info {
        [self.dataSource removeObject:info];
}

- (BOOL)onlineWithUserId:(NSInteger)userId {
    MSOnlineInfo *onlineInfo = [MSOnlineInfo findFirstByCriteria:[NSString stringWithFormat:@"where userId=%ld",(long)userId]];
    if (!onlineInfo) {
        return NO;
    }
    return onlineInfo.online;
}

- (void)startOnlineChangedEvent {    
    [self rollingChangeUserOnlineStatus];
}

- (void)rollingChangeUserOnlineStatus {
    dispatch_async(self.sourceQueue, ^{
        __block uint nextRollingReplyTime = kRollingChangeTimeInterval;
        
        if (self.dataSource.count > 0) {
            [self.dataSource enumerateObjectsUsingBlock:^(MSOnlineInfo * _Nonnull onlineInfo, NSUInteger idx, BOOL * _Nonnull stop) {
                NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
                if (onlineInfo.changeTime <= currentTimeInterval) {
                    
                    onlineInfo.online = !onlineInfo.online;//更改在线状态
                    
                    if (onlineInfo.type == MSUserTypeNewPush) {
                        //在没有重置今日推送之前 不做处理
                        [self removeUser:onlineInfo];
                        if (self.replyLastPushUser) {
                            //若当日最后一个机器人也离线了 则重置推送机器人逻辑
                            [self setAllPushUserOffline];
                        }
                    } else if (onlineInfo.type == MSUserTypeOldPush) {
                        //循环更新
                        onlineInfo.changeTime = currentTimeInterval + PushUserOldPushTime;
                        [self addUser:onlineInfo];
                    } else if (onlineInfo.type == MSUserTypeCircle) {
                        //循环更新
                        onlineInfo.changeTime = currentTimeInterval + CircleUserNormalTime;
                        [self addUser:onlineInfo];
                    }
                    
                    if ([onlineInfo saveOrUpdate]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:kMSPostOnlineInfoNotification object:onlineInfo];
                        });
                    }
                } else {
                    NSTimeInterval nextTime = onlineInfo.changeTime - [[NSDate date] timeIntervalSince1970];
                    if (nextTime < nextRollingReplyTime) {
                        nextRollingReplyTime = nextTime;
                    }
                    *stop = YES;
                }
            }];
        }
//        QBLog(@"状态改变池数量%ld 下次判断改变时间 %d",self.dataSource.count,nextRollingReplyTime);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            sleep(nextRollingReplyTime);
            [self rollingChangeUserOnlineStatus];
        });
    });
}

@end
