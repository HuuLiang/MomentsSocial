//
//  MSTuRingManager.m
//  MomentsSocial
//
//  Created by Liang on 2017/9/15.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSTuRingManager.h"
#import <AFNetworking.h>

static NSString *kMSTuRingReplyCountKeyName = @"kMSTuRingReplyCountKeyName";

@interface MSTuRingManager ()
@property (nonatomic,strong) AFHTTPSessionManager *sessionManager;
@end

@implementation MSTuRingManager

+ (instancetype)manager {
    static MSTuRingManager *_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[MSTuRingManager alloc] init];
    });
    return _manager;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager) {
        return _sessionManager;
    }
    
    _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [_sessionManager.requestSerializer setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain",nil];
    return _sessionManager;
}

- (BOOL)shoudReply {
    if ([MSUtil isToday]) {
        NSInteger alReadyReplyCount = [[[NSUserDefaults standardUserDefaults] objectForKey:kMSTuRingReplyCountKeyName] integerValue];
        NSInteger maxCount = [MSUtil currentVipLevel] == MSLevelVip0 ? 5 : 9999999;
        if (alReadyReplyCount < maxCount) {
            return @(arc4random() % 2).boolValue;
        } else {
            return NO;
        }
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:kMSTuRingReplyCountKeyName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return @(arc4random() % 2).boolValue;
    }
}

- (void)sendMsgToQinYunKe:(NSString *)msgContent userId:(NSInteger)userId handler:(void (^)(NSString *))handler {
    if (![self shoudReply]) {
        return;
    }
    NSString *reqUrl = [NSString stringWithFormat:@"%@%@",MS_QINGYUNKE_URL,[msgContent stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self.sessionManager GET:reqUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"result"] integerValue] == 0) {
            NSInteger alReadyReplyCount = [[[NSUserDefaults standardUserDefaults] objectForKey:kMSTuRingReplyCountKeyName] integerValue];
            alReadyReplyCount += 1;
            [[NSUserDefaults standardUserDefaults] setObject:@(alReadyReplyCount) forKey:kMSTuRingReplyCountKeyName];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            handler(responseObject[@"content"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

//- (void)sendMsgToTuRing:(NSString *)msgContent userId:(NSInteger)userId handler:(void (^)(NSString *))handler {
//    if (![self shoudReply]) {
//        return;
//    }
//    
//    NSDictionary *params = @{@"key":MS_TULING_KEY,
//                             @"info":msgContent,
//                             @"userid":[NSString stringWithFormat:@"%ld",(long)userId]};
//    [self.sessionManager POST:MS_TURING_URL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        if ([responseObject[@"code"] integerValue] == 100000) {
//            NSInteger alReadyReplyCount = [[[NSUserDefaults standardUserDefaults] objectForKey:kMSTuRingReplyCountKeyName] integerValue];
//            alReadyReplyCount += 1;
//            [[NSUserDefaults standardUserDefaults] setObject:@(alReadyReplyCount) forKey:kMSTuRingReplyCountKeyName];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            
//            handler(responseObject[@"text"]);
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        
//    }];
//}


@end
