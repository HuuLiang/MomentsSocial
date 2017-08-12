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
    return @[@"phone",@"sex",@"age",@"marital",@"weight",@"weixin",@"portraitUrl",@"income",@"birthday",@"nickName",@"city",@"education",@"qq",@"vocation",@"height",@"constellation",@"userPhoto",@"vipLv"];
}

- (BOOL)greeted {
    MSUserModel *userModel = [MSUserModel findFirstByCriteria:[NSString stringWithFormat:@"%ld",self.userId]];
    if (!userModel) {
        return NO;
    }
    return userModel.greeted;
}

@end
