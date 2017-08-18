//
//  MSUserModel.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/5.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSUserModel.h"

@implementation MSUserMsgModel

@end

@implementation MSUserModel

- (Class)userPhotoElementClass {
    return [NSString class];
}

- (Class)messageElementClass {
    return [MSUserMsgModel class];
}

+ (NSArray *)transients {
    return @[@"phone",@"sex",@"age",@"marital",@"weight",@"weixin",@"portraitUrl",@"income",@"birthday",@"nickName",@"city",@"education",@"qq",@"vocation",@"height",@"constellation",@"userPhoto",@"vipLv",@"message"];
}

- (BOOL)isGreeted {
    if (_userId == 10000262) {
        
    }
    MSUserModel *userModel = [MSUserModel findFirstByCriteria:[NSString stringWithFormat:@"where userId=%ld",(long)_userId]];
    if (!userModel) {
        return NO;
    }
    return userModel.greeted;
}

+ (BOOL)isGreetedWithUserId:(NSInteger)userId {
    MSUserModel *userModel = [MSUserModel findFirstByCriteria:[NSString stringWithFormat:@"where userId=%ld",(long)userId]];
    if (!userModel) {
        return NO;
    }
    return userModel.greeted;
}

@end
