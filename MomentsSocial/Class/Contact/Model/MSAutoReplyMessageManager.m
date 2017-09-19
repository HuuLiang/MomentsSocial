//
//  MSAutoReplyMessageManager.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/9.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSAutoReplyMessageManager.h"
#import "MSReqManager.h"
#import "MSSystemConfigModel.h"
#import "MSContactModel.h"
#import "MSMessageModel.h"
#import "MSLocalNotificationManager.h"
#import "MSOnlineManager.h"
#import "MSTuRingManager.h"

static const NSUInteger kRollingTimeInterval = 5;
static const NSTimeInterval firstPushTime = 0;
//static const NSTimeInterval secondPushTime = 60 * 30;
//static const NSTimeInterval thirdPushTime = 60 * 60;

static NSString *const kMSAutoReplyMsgObserveTimeKeyName    = @"kMSAutoReplyMsgObserveTimeKeyName";
static NSString *const kMSAutoReplyMsgPageCountKeyName      = @"kMSAutoReplyMsgPageCountKeyName";


@interface MSAutoReplyMessageManager ()
@property (nonatomic,strong) dispatch_queue_t replyQueue;
@property (nonatomic,strong) dispatch_queue_t dataQueue;
@property (nonatomic,strong) dispatch_source_t timer;
@property (nonatomic) __block NSUInteger observeTime;
@property (nonatomic) __block NSNumber   *reqPage;
@property (nonatomic) __block NSMutableArray <MSAutoReplyMsg *> *dataSource;
@end

@implementation MSAutoReplyMessageManager
QBDefineLazyPropertyInitialization(NSMutableArray, dataSource)

+ (instancetype)manager {
    static MSAutoReplyMessageManager *_autoReplyManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _autoReplyManager = [[MSAutoReplyMessageManager alloc] init];
    });
    return _autoReplyManager;
}

- (void)startAutoReplyMsgEvent {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteNoReplyMsg) name:MSOpenVipSuccessNotification object:nil];
    
    [[MSLocalNotificationManager manager] startAutoLocalNotification]; //开启本地轮询通知
    [self deleteYesterdayMessages]; //删除过期数据
    if ([MSUtil currentVipLevel] == MSLevelVip0) {
        [self loadAutoReplyMsgsCache];  //加载今日未推送消息
        [self observeAutoReplyTimeInterval]; //开始监控启动时常 获取批量推送消息
    }
}

- (void)deleteNoReplyMsg {
    [MSAutoReplyMsg deleteAllAutoReplyMsgInfo];
    [self operateReplySource:nil type:MSReplyDataSourceTypeDelAll];
}

- (void)deleteYesterdayMessages {
    [[MSOnlineManager manager] resetAllOnlineInfo]; //重置所有在线状态
    [MSContactModel deletePastContactInfo]; //清空消息列表过期数据
    [MSMessageModel deletePastMessageInfo]; //清空聊天详情过期数据
    [MSAutoReplyMsg deletePastAutoReplyMsgInfo]; //清空自动回复池过期数据
}

- (void)observeAutoReplyTimeInterval {
    NSInteger pushRate = [MSSystemConfigModel defaultConfig].config.PUSH_RATE;
    NSInteger pushTime  = [MSSystemConfigModel defaultConfig].config.PUSH_TIME/1000;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
    dispatch_source_set_timer(_timer, delayTime, 1*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        //执行事件
//        QBLog(@"注意当前的计时器时间 %ld",(long)self.observeTime);
        if (_observeTime == firstPushTime || _observeTime % pushTime == 0) {
            [self fetchBatchReplyUsersInfoWithPage:[self.reqPage integerValue] handler:^(BOOL success) {
                if (success) {
                    self.reqPage = @([self.reqPage integerValue] + 1);
                } else {
                    self.reqPage = @(1);
                }
                [[NSUserDefaults standardUserDefaults] setObject:self.reqPage forKey:kMSAutoReplyMsgPageCountKeyName];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }];
            
        }
        _observeTime++;
        [[NSUserDefaults standardUserDefaults] setObject:@(_observeTime) forKey:kMSAutoReplyMsgObserveTimeKeyName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    });
    
    self.observeTime = [[[NSUserDefaults standardUserDefaults] objectForKey:kMSAutoReplyMsgObserveTimeKeyName] integerValue];
    self.reqPage = [[NSUserDefaults standardUserDefaults] objectForKey:kMSAutoReplyMsgPageCountKeyName];
    if (!_reqPage) {
        _reqPage = @(1);
    }
    
    if ([MSUtil currentVipLevel] < MSLevelVip2) {
        if (![MSUtil isToday]) {
            //判断 不是今天 刷新在线市场计时器
            _observeTime = 0;
            [[NSUserDefaults standardUserDefaults] setObject:@(_observeTime) forKey:kMSAutoReplyMsgObserveTimeKeyName];
            [[NSUserDefaults standardUserDefaults] synchronize];
            dispatch_resume(_timer);
        } else {
            //是今天 沿用保存的时间继续开始计时器
            if (_observeTime > pushTime * (pushRate - 1)) {
                //如果在线时间超过规定的时间 则不做处理
                dispatch_source_cancel(_timer);
                return;
            } else {
                //如果不超出规定时间 则继续计时
                dispatch_resume(_timer);
            }
        }
    }
}

- (void)fetchBatchReplyUsersInfoWithPage:(NSInteger)page handler:(void(^)(BOOL success))handler {
    [[MSReqManager manager] fetchPushUserInfoWithPage:page size:[MSSystemConfigModel defaultConfig].config.PUSH_COUNT Class:[MSAutoReplyBatchResponse class] completionHandler:^(BOOL success, MSAutoReplyBatchResponse * obj) {
        if (success) {
            [self insertUserMsgIntoReplyCache:obj.pushUser sort:YES];
        }
        handler(obj.pushUser.count > 0);
    }];
}

- (void)fetchOneReplyUserInfo {
//    [[MSReqManager manager] fetchOneUserInfoClass:[MSAutoReplyOneResponse class] completionHandler:^(BOOL success, MSAutoReplyOneResponse * obj) {
//        if (success) {
//            [self insertUserMsgIntoReplyCache:@[obj.user] sort:YES];
//        }
//    }];
}

- (void)fetchOneUserMessageInfoWithUserId:(NSString *)userId {
    @weakify(self);
    [[MSReqManager manager] fetchOneUserInfoClass:[MSAutoReplyOneResponse class] withUserId:userId completionHandler:^(BOOL success, MSAutoReplyOneResponse * obj) {
        @strongify(self);
        if (success && obj.user) {
            [self insertUserMsgIntoReplyCache:@[obj.user] sort:YES];
        }
    }];
}

- (void)fetchKeywordReplyMsgWithMsgInfo:(MSMessageModel *)messageModel{
    NSString *content = @"";
    if (messageModel.msgType == MSMessageTypeText) {
        content = messageModel.msgContent;
    } else if (messageModel.msgType == MSMessageTypeVoice) {
        content = messageModel.voiceUrl;
    } else if (messageModel.msgType == MSMessageTypePhoto) {
        content = messageModel.imgUrl;
    }
    [[MSReqManager manager] sendMsgWithSendUserId:messageModel.sendUserId receiveUserId:messageModel.receiveUserId content:content Class:[MSKeywordsReplyResponse class] completionHandler:^(BOOL success, MSKeywordsReplyResponse * userMsg) {
//        if (success) {
//            if (!userMsg.message) {
//                return ;
//            }
//            MSAutoReplyMsg *replyMsg = [[MSAutoReplyMsg alloc] init];
//            replyMsg.userId = [messageModel.receiveUserId integerValue];
//            replyMsg.portraitUrl = messageModel.portraitUrl;
//            replyMsg.nickName = messageModel.nickName;
//            replyMsg.msgId = userMsg.message.msgId;
//            replyMsg.msgType = userMsg.message.msgType;
//            if (replyMsg.msgType == MSMessageTypePhoto) {
//                replyMsg.imgUrl = userMsg.message.photoUrl;
//            } else if (replyMsg.msgType == MSMessageTypeVoice) {
//                replyMsg.voiceUrl = userMsg.message.voiceUrl;
//                replyMsg.voiceDuration = [NSString stringWithFormat:@"%.1f",[MSUtil getVideoLengthWithVideoUrl:userMsg.message.voiceUrl]];
//            } else if (replyMsg.msgType == MSMessageTypeVideo) {
//                replyMsg.videoImgUrl = userMsg.message.videoImg;
//                replyMsg.videoUrl = userMsg.message.videoUrl;
//            } else {
//                replyMsg.msgContent = userMsg.message.content;
//            }
//            
//            replyMsg.msgTime = [[NSDate date] timeIntervalSince1970]  + arc4random() % 10;
//            if ([replyMsg saveOrUpdate]) {
//                [[MSAutoReplyMessageManager manager] operateReplySource:@[replyMsg] type:MSReplyDataSourceTypeSort];
//            }
//        }
    }];
}

- (void)fetchAIReplyMsgWithMsgInfo:(MSMessageModel *)messageModel {
    NSString *content = @"";
    if (messageModel.msgType == MSMessageTypeText) {
        content = messageModel.msgContent;
    } else {
        return;
    }
//    [[MSTuRingManager manager] sendMsgToTuRing:messageModel.msgContent userId:[messageModel.receiveUserId integerValue] handler:^(NSString *msg) {
//        MSAutoReplyMsg *replyMsg = [[MSAutoReplyMsg alloc] init];
//        replyMsg.userId = [messageModel.receiveUserId integerValue];
//        replyMsg.portraitUrl = messageModel.portraitUrl;
//        replyMsg.nickName = messageModel.nickName;
//        replyMsg.msgId = 0;
//        replyMsg.msgType = MSMessageTypeText;
//        replyMsg.msgContent = msg;
//        
//        replyMsg.msgTime = [[NSDate date] timeIntervalSince1970]  + arc4random() % 90 + 30;
//        if ([replyMsg saveOrUpdate]) {
//            [[MSAutoReplyMessageManager manager] operateReplySource:@[replyMsg] type:MSReplyDataSourceTypeSort];
//        }
//    }];
    
    [[MSTuRingManager manager] sendMsgToQinYunKe:messageModel.msgContent userId:[messageModel.receiveUserId integerValue] handler:^(NSString * msg) {
        MSAutoReplyMsg *replyMsg = [[MSAutoReplyMsg alloc] init];
        replyMsg.userId = [messageModel.receiveUserId integerValue];
        replyMsg.portraitUrl = messageModel.portraitUrl;
        replyMsg.nickName = messageModel.nickName;
        replyMsg.msgId = 0;
        replyMsg.msgType = MSMessageTypeText;
        replyMsg.msgContent = msg;
        
        replyMsg.msgTime = [[NSDate date] timeIntervalSince1970]  + arc4random() % 90 + 30;
        if ([replyMsg saveOrUpdate]) {
            [[MSAutoReplyMessageManager manager] operateReplySource:@[replyMsg] type:MSReplyDataSourceTypeSort];
        }
    }];
}

- (void)insertUserMsgIntoReplyCache:(NSArray <MSUserModel *> *)users sort:(BOOL)sort {
    __block NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970]; //初始化回复时间

    NSMutableArray <MSAutoReplyMsg *> * replyMsgsSource = [[NSMutableArray alloc] init];
    
    [users enumerateObjectsUsingBlock:^(MSUserModel * _Nonnull userModel, NSUInteger userIndex, BOOL * _Nonnull stop) {
        if (userIndex == 0) {
            timeInterval = timeInterval + 10; //初始化first user回复时间 延迟 10s
        } else {
#ifdef DEBUG
            timeInterval = timeInterval + 10;
#else
            timeInterval = timeInterval + arc4random() % 61 + 60; //初始化后续user的回复时间 间隔 60-120s
//            timeInterval = timeInterval + 10;
#endif
        }
        
        __block NSTimeInterval userMsgTime = timeInterval; //初始化user消息回复时间
        __block NSTimeInterval randomTime = 0;
        [userModel.message enumerateObjectsUsingBlock:^(MSUserMsgModel * _Nonnull msgModel, NSUInteger msgIndex, BOOL * _Nonnull stop) {
#ifdef DEBUG
            userMsgTime += 4;
#else
            randomTime += arc4random() % 21 + 20; //单个user的每条消息的时间间隔 间隔递增 20-40s
            userMsgTime += randomTime;
//            randomTime += arc4random() % 5 + 5;
//            userMsgTime += randomTime;
#endif
            MSAutoReplyMsg *replyMsg = [MSAutoReplyMsg findFirstByCriteria:[NSString stringWithFormat:@"where msgId=%ld",(long)msgModel.msgId]];
            if (!replyMsg) {
                replyMsg = [[MSAutoReplyMsg alloc] init];
                replyMsg.userId = userModel.userId;
                replyMsg.portraitUrl = userModel.portraitUrl;
                replyMsg.nickName = userModel.nickName;
                replyMsg.msgId = msgModel.msgId;
                replyMsg.msgType = msgModel.msgType;
                if (replyMsg.msgType == MSMessageTypePhoto) {
                    replyMsg.imgUrl = msgModel.photoUrl;
                } else if (replyMsg.msgType == MSMessageTypeVoice) {
                    replyMsg.voiceUrl = msgModel.voiceUrl;
                    replyMsg.voiceDuration = [NSString stringWithFormat:@"%.1f",[MSUtil getVideoLengthWithVideoUrl:msgModel.voiceUrl]];
                } else if (replyMsg.msgType == MSMessageTypeVideo) {
                    replyMsg.videoImgUrl = msgModel.videoImg;
                    replyMsg.videoUrl = msgModel.videoUrl;
                } else {
                    replyMsg.msgContent = msgModel.content;
                }
                
                replyMsg.msgTime = userMsgTime;
                
                if ([replyMsg saveOrUpdate]) {
                    [replyMsgsSource addObject:replyMsg];
                }
            }
        }];
    }];
    
    if (sort) {
        [self operateReplySource:replyMsgsSource type:MSReplyDataSourceTypeSort];
    }
    
    if (self.dataSource.count > 0) {
        [self activateRollingAutoReplyMsgsEvent];
    }
}

- (void)activateRollingAutoReplyMsgsEvent {
    //如果推送进程已经运行中 返回
    if (self.replyQueue) {
        return;
    }

    self.replyQueue = dispatch_queue_create("MomentsSocial.AutoReplyMsg.Queue", nil);

    [self rollingAutoReplyMsgs];
}

- (void)loadAutoReplyMsgsCache {
    [self.dataSource removeAllObjects];
    NSArray <MSAutoReplyMsg *> *oldReplyMsgs = [MSAutoReplyMsg findAll];
    //如果还有今日消息未备推送 则立即启动推送循环
    if (oldReplyMsgs.count > 0) {
        [self operateReplySource:oldReplyMsgs type:MSReplyDataSourceTypeSort];
    }
}

- (void)operateReplySource:(NSArray <MSAutoReplyMsg *> *)replyMsgs type:(MSReplyDataSourceType)type {
    if (!self.dataQueue) {
        self.dataQueue = dispatch_queue_create("MomentsSocial.OperateSource.Queue", nil);
    }
    dispatch_async(self.dataQueue, ^{
        if (type == MSReplyDataSourceTypeAdd) {
            [self.dataSource addObjectsFromArray:replyMsgs];
        } else if (type == MSReplyDataSourceTypeDel) {
            [self.dataSource removeObjectsInArray:replyMsgs];
        } else if (type == MSReplyDataSourceTypeSort) {
            [self.dataSource addObjectsFromArray:replyMsgs];
            
            [self.dataSource sortWithOptions:NSSortStable
                             usingComparator:^NSComparisonResult(MSAutoReplyMsg *  _Nonnull replyMsg1, MSAutoReplyMsg *  _Nonnull replyMsg2)
            {
                if (replyMsg1.msgTime > replyMsg2.msgTime) {
                    return NSOrderedDescending;
                } else if (replyMsg1.msgTime < replyMsg2.msgTime) {
                    return NSOrderedAscending;
                } else {
                    return NSOrderedSame;
                }
            }];
        } else if (type == MSReplyDataSourceTypeDelAll) {
            [self.dataSource removeAllObjects];
        }
        
        if (self.dataSource == 0 && self.observeTime > [MSSystemConfigModel defaultConfig].config.PUSH_TIME * ([MSSystemConfigModel defaultConfig].config.PUSH_RATE - 1)) {
            [MSOnlineManager manager].replyLastPushUser = YES;
        }
        
        if (self.dataSource.count > 0) {
            [self activateRollingAutoReplyMsgsEvent];
        }
    });
}

- (void)rollingAutoReplyMsgs {
//    [self.dataSource enumerateObjectsUsingBlock:^(MSAutoReplyMsg * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"nickName:%@ type:%ld time:%ld",obj.nickName,(MSMessageType)obj.msgType,(long)obj.msgTime);
//    }];
    
    dispatch_async(self.replyQueue, ^{
        __block uint nextRollingReplyTime = kRollingTimeInterval;
        
        NSArray *copyDataSource = self.dataSource.mutableCopy;
        if (copyDataSource.count > 0) {
            [copyDataSource enumerateObjectsUsingBlock:^(MSAutoReplyMsg * _Nonnull replyMsg, NSUInteger idx, BOOL * _Nonnull stop) {
                NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
//                NSLog(@"idx=%ld nickName:%@ type:%ld time:%ld",(long)idx,replyMsg.nickName,(MSMessageType)replyMsg.msgType,(long)replyMsg.msgTime);
                if (replyMsg.msgTime <= currentTimeInterval) {
                    [self postReplyMsg:replyMsg];
                } else {
                    NSTimeInterval nextTime = replyMsg.msgTime - [[NSDate date] timeIntervalSince1970];
                    if (nextTime < nextRollingReplyTime) {
                        nextRollingReplyTime = nextTime;
                    }
                    *stop = YES;
                }
            }];
        }
        
//        QBLog(@"回复池数量%ld 下次循环推送时间 %d",self.dataSource.count,nextRollingReplyTime);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            sleep(nextRollingReplyTime);
            [self rollingAutoReplyMsgs];
        });
    });
}

- (void)postReplyMsg:(MSAutoReplyMsg *)replyMsg {
//    if ([MSUtil currentVipLevel] == MSLevelVip0) {
        [[MSOnlineManager manager] addUser:replyMsg.userId type:MSUserTypeNewPush handler:^(BOOL online) {
            
        }];//加入在线管理器
        [MSMessageModel addMessageInfoWithReplyMsg:replyMsg]; //加入聊天详情表
        if ([MSContactModel addContactInfoWithReplyMsg:replyMsg]) {
            //加入消息详情表
            [replyMsg deleteObject];
            [self operateReplySource:@[replyMsg] type:MSReplyDataSourceTypeDel];
        }
//    } else {
//        [replyMsg deleteObject];
//        [self operateReplySource:@[replyMsg] type:MSReplyDataSourceTypeDel];
//    }
}

@end



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation MSAutoReplyMsg

+ (void)deletePastAutoReplyMsgInfo {
    [[MSAutoReplyMsg findAll] enumerateObjectsUsingBlock:^(MSAutoReplyMsg * _Nonnull replyMsg, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![[NSDate dateWithTimeIntervalSince1970:replyMsg.msgTime] isToday]) {
            [replyMsg deleteObject];
        }
    }];
}

+ (void)deleteAllAutoReplyMsgInfo {
    [MSAutoReplyMsg clearTable];
}

@end



@implementation MSAutoReplyOneResponse
- (Class)userClass {
    return [MSUserModel class];
}
@end


@implementation MSAutoReplyBatchResponse

- (Class)pushUserElementClass {
    return [MSUserModel class];
}

@end


@implementation MSKeywordsReplyResponse

- (Class)messageClass {
    return [MSUserMsgModel class];
}

@end
