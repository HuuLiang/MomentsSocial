//
//  MSUserModel.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/5.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSUserModel.h"

@implementation MSUserModel

- (Class)userPhotoElementClass {
    return [MSUserModel class];
}

+ (NSArray *)transients {
    return @[@"phone",@"sex",@"age",@"marital",@"weight",@"weixin",@"portraitUrl",@"income",@"birthday",@"nickName",@"city",@"education",@"qq",@"vocation",@"height",@"constellation",@"userPhoto",@"vipLv"];
}

@end
