//
//  MSMessageModel.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMessageModel.h"

@implementation MSMessageModel

+ (NSArray<MSMessageModel *> *)allMessagesWithUserId:(NSString *)userId {
    NSArray  <MSMessageModel *> * allMsgs = [self findByCriteria:[NSString stringWithFormat:@"WHERE sendUserId=\'%@\' or receiveUserId=\'%@\'",userId,userId]];
    return allMsgs;
}

@end
