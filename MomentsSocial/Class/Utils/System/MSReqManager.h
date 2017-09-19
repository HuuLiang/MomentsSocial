//
//  MSReqManager.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSReqManager : NSObject

+ (instancetype)manager;

/** 激活 */
- (void)registerUUIDClass:(Class)classModel completionHandler:(MSCompletionHandler)handler;

/** 系统配置 */
- (void)fetchSystemConfigInfoClass:(Class)classModel completionHandler:(MSCompletionHandler)handler;

/** 秘爱 圈子 */
- (void)fetchCircleInfoWithCircleId:(NSInteger)circleId Class:(Class)classModel completionHandler:(MSCompletionHandler)handler;

/** 动态 */
- (void)fetchMomentsListInfoWithCircleId:(NSInteger)circleId class:(Class)classModel completionHandler:(MSCompletionHandler)handler;

/** 今日开房 */
- (void)fetchDayHouseInfoClass:(Class)classModel completionHandler:(MSCompletionHandler)handler;

/** 批量推送 */
- (void)fetchPushUserInfoWithPage:(NSInteger)page size:(NSInteger)pageSize Class:(Class)classModel completionHandler:(MSCompletionHandler)handler;

/** 单个推送用户 */
- (void)fetchOneUserInfoClass:(Class)classModel withUserId:(NSString *)userId completionHandler:(MSCompletionHandler)handler;

/** 摇一摇 附近的人 */
- (void)fetchNearShakeInfoWithNumber:(NSInteger)userCount Class:(Class)classModel completionHandler:(MSCompletionHandler)handler;

/** 详情 */
- (void)fetchDetailInfoWithUserId:(NSString *)userId Class:(Class)classModel completionHandler:(MSCompletionHandler)handler;

/** 发现 */
- (void)fetchDiscoverInfoClass:(Class)classModel completionHandler:(MSCompletionHandler)handler;

/** 评论列表 */
- (void)fetchCommentsWithMomentId:(NSInteger)momentId Class:(Class)classModel completionHandler:(MSCompletionHandler)handler;

/** 点赞 */
- (void)greetMomentWithMoodId:(NSInteger)moodId Class:(Class)classModel completionHandler:(MSCompletionHandler)handler;

/** 发送消息 */
- (void)sendMsgWithSendUserId:(NSString *)sendUserId receiveUserId:(NSString *)receiveUserId content:(NSString *)content Class:(Class)classModel completionHandler:(MSCompletionHandler)handler;
@end
