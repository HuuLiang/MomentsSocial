//
//  MSReqManager.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSReqManager.h"
#import "QBDataManager.h"
#import "QBDataResponse.h"

@implementation MSReqManager

+ (instancetype)manager {
    static MSReqManager *_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[MSReqManager alloc] init];
        [QBDataConfiguration configuration].baseUrl = MS_BASE_URL;
    });
    return _manager;
}

- (NSDictionary *)params {
    NSDictionary *baseParams = @{@"appId":MS_REST_APPID,
                                 @"channelNo":MS_CHANNEL_NO,
                                 @"appVersion":MS_REST_APP_VERSION,
                                 @"cVersion":MS_CONTENT_VERSION};
    return baseParams;
}

- (BOOL)checkResponseCodeObject:(id)obj error:(NSError *)error {
    QBLog(@"obj=%@ error = %@",obj,error);
    
    if (!obj || error) {
        return NO;
    }
    
    QBDataResponse *resp = obj;
    NSInteger respCode = [resp.code integerValue];
    if (respCode == 200) {
        return YES;
    } else if (respCode == 300) {
        [[MSHudManager manager] showHudWithText:@"参数不正确"];
        return NO;
    } else if (respCode == 301) {
        [[MSHudManager manager] showHudWithText:@"用户不存在"];
        return NO;
    } else if (respCode == 307) {
        [[MSHudManager manager] showHudWithText:@"更新失败"];
        return NO;
    } else if (respCode == 400) {
        [[MSHudManager manager] showHudWithText:@"解密失败"];
        return NO;
    } else if (respCode == 401) {
        [[MSHudManager manager] showHudWithText:@"签名不通过"];
        return NO;
    } else if (respCode == 500) {
        [[MSHudManager manager] showHudWithText:@"系统异常"];
        return NO;
    }
    return NO;
}


- (void)registerUUIDClass:(Class)classModel completionHandler:(MSCompletionHandler)handler {
    [[QBDataManager manager] requestUrl:MS_ACTIVATION_URL withParams:[self params] class:classModel handler:^(id obj, NSError *error) {
        handler([self checkResponseCodeObject:obj error:error],obj);
    }];
}

- (void)fetchSystemConfigInfoClass:(Class)classModel completionHandler:(MSCompletionHandler)handler {
    [[QBDataManager manager] requestUrl:MS_SYSTEMCONFIG_URL withParams:[self params] class:classModel handler:^(id obj, NSError *error) {
        handler([self checkResponseCodeObject:obj error:error],obj);
    }];
}

- (void)fetchCircleInfoWithCircleId:(NSInteger)circleId Class:(Class)classModel completionHandler:(MSCompletionHandler)handler {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[self params]];
    if (circleId != NSNotFound) {
        [params addEntriesFromDictionary:@{@"circleId":@(circleId)}];
    }

    [[QBDataManager manager] requestUrl:MS_HOME_URL withParams:params class:classModel handler:^(id obj, NSError *error) {
        handler([self checkResponseCodeObject:obj error:error],obj);
    }];
}

- (void)fetchMomentsListInfoWithCircleId:(NSInteger)circleId class:(Class)classModel completionHandler:(MSCompletionHandler)handler {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[self params]];
    if (circleId != NSNotFound) {
        [params addEntriesFromDictionary:@{@"circleId":@(circleId),
                                           @"pageSize":@(100)}];
    }
    
    [[QBDataManager manager] requestUrl:MS_MOMENTS_URL withParams:params class:classModel handler:^(id obj, NSError *error) {
        handler([self checkResponseCodeObject:obj error:error],obj);
    }];
}

- (void)fetchDayHouseInfoClass:(Class)classModel completionHandler:(MSCompletionHandler)handler {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[self params]];
    [params addEntriesFromDictionary:@{@"userId":@([MSUtil currentUserId])}];

    [[QBDataManager manager] requestUrl:MS_DAYHOUSE_URL withParams:params class:classModel handler:^(id obj, NSError *error) {
        handler([self checkResponseCodeObject:obj error:error],obj);
    }];
}

/** 批量推送 */
- (void)fetchPushUserInfoWithPage:(NSInteger)page size:(NSInteger)pageSize Class:(Class)classModel completionHandler:(MSCompletionHandler)handler {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[self params]];
    [params addEntriesFromDictionary:@{@"page":@(page)}];
    if (pageSize > 0) {
        [params addEntriesFromDictionary:@{@"pageSize":@(pageSize)}];
    }
    
    [[QBDataManager manager] requestUrl:MS_PUSHUSER_URL withParams:params class:classModel handler:^(id obj, NSError *error) {
        handler([self checkResponseCodeObject:obj error:error],obj);
    }];
}

//随机获取单个用户的信息
- (void)fetchOneUserInfoClass:(Class)classModel withUserId:(NSString *)userId completionHandler:(MSCompletionHandler)handler {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[self params]];
    [params addEntriesFromDictionary:@{@"userId":userId}];
    [[QBDataManager manager] requestUrl:MS_PUSHUSERONE_URL withParams:params class:classModel handler:^(id obj, NSError *error) {
        handler([self checkResponseCodeObject:obj error:error],obj);
    }];
}

/** 摇一摇 附近的人 */
- (void)fetchNearShakeInfoWithNumber:(NSInteger)userCount Class:(Class)classModel completionHandler:(MSCompletionHandler)handler {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[self params]];
    [params addEntriesFromDictionary:@{@"number":@(userCount),
                                       @"userId":@([MSUtil currentUserId])}];
    
    [[QBDataManager manager] requestUrl:MS_NEARSHAKE_URL withParams:params class:classModel handler:^(id obj, NSError *error) {
        handler([self checkResponseCodeObject:obj error:error],obj);
    }];
}

- (void)fetchDetailInfoWithUserId:(NSString *)userId Class:(Class)classModel completionHandler:(MSCompletionHandler)handler {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[self params]];
    [params addEntriesFromDictionary:@{@"userId":userId}];
    
    [[QBDataManager manager] requestUrl:MS_USER_URL withParams:params class:classModel handler:^(id obj, NSError *error) {
        handler([self checkResponseCodeObject:obj error:error],obj);
    }];
}

- (void)fetchDiscoverInfoClass:(Class)classModel completionHandler:(MSCompletionHandler)handler {
    [[QBDataManager manager] requestUrl:MS_DISCOVER_URL withParams:[self params] class:classModel handler:^(id obj, NSError *error) {
        handler([self checkResponseCodeObject:obj error:error],obj);
    }];
}

- (void)fetchCommentsWithMomentId:(NSInteger)momentId Class:(Class)classModel completionHandler:(MSCompletionHandler)handler {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[self params]];
    [params addEntriesFromDictionary:@{@"moodId":@(momentId)}];
    
    [[QBDataManager manager] requestUrl:MS_COMMENT_URL withParams:params class:classModel handler:^(id obj, NSError *error) {
        handler([self checkResponseCodeObject:obj error:error],obj);
    }];
}

- (void)greetMomentWithMoodId:(NSInteger)moodId Class:(Class)classModel completionHandler:(MSCompletionHandler)handler {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[self params]];
    [params addEntriesFromDictionary:@{@"moodId":@(moodId)}];
    
    [[QBDataManager manager] requestUrl:MS_LIKES_URL withParams:params class:classModel handler:^(id obj, NSError *error) {
        handler([self checkResponseCodeObject:obj error:error],obj);
    }];
}

- (void)sendMsgWithSendUserId:(NSString *)sendUserId receiveUserId:(NSString *)receiveUserId content:(NSString *)content Class:(Class)classModel completionHandler:(MSCompletionHandler)handler {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[self params]];
    [params addEntriesFromDictionary:@{@"sendUserId":sendUserId,
                                       @"receiveUserId":receiveUserId,
                                       @"content":content}];
    
    [[QBDataManager manager] requestUrl:MS_SENDMSG_URL withParams:params class:classModel handler:^(id obj, NSError *error) {
        handler([self checkResponseCodeObject:obj error:error],obj);
    }];
}

@end
