//
//  MSReqManager.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSReqManager.h"
#import "QBDataManager.h"

#import "MSActivityModel.h"
#import "MSHomeModel.h"

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

- (BOOL)checkResponseCodeObject:(id)obj error:(NSError *)error {
    QBLog(@"obj=%@ error = %@",obj,error);
    
    if (!obj || error) {
        return NO;
    }
    
    QBDataResponse *resp = obj;
    NSInteger respCode = [resp.code integerValue];
    if (respCode == 200) {
        return YES;
    } else {
        return NO;
    }
}


- (void)registerUUIDWithCompletionHandler:(MSCompletionHandler)handler {
    [[QBDataManager manager] requestUrl:MS_ACTIVATION_URL withParams:nil class:[MSActivityModel class] handler:^(MSActivityModel * obj, NSError *error) {
        handler([self checkResponseCodeObject:obj error:error],obj.uuid);
    }];
}

- (void)fetchHomeInfoWithCompletionHandler:(MSCompletionHandler)handler {
    [[QBDataManager manager] requestUrl:MS_HOME_URL withParams:nil class:[MSHomeModel class] handler:^(id obj, NSError *error) {
        handler([self checkResponseCodeObject:obj error:error],obj);
    }];
}

@end
