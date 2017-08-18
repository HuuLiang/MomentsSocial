//
//  MSMomentsModel.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/31.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMomentsModel.h"
#import "MSUserModel.h"

@implementation MSMomentCommentsInfo

@end

@implementation MSMomentModel

- (Class)moodUrlElementClass {
    return [NSString class];
}

- (Class)commentsElementClass {
    return [MSMomentCommentsInfo class];
}

- (void)setUserGreeted:(BOOL)greeted {
    MSUserModel *userModel = [MSUserModel findFirstByCriteria:[NSString stringWithFormat:@"where userId=%ld",(long)_userId]];
    if (!userModel) {
        userModel = [[MSUserModel alloc] init];
    }
    userModel.userId = _userId;
    userModel.greeted = greeted;
    
    [userModel saveOrUpdate];
}

- (BOOL)isGreeted {
    return [MSUserModel isGreetedWithUserId:_userId];
}

- (BOOL)isLoved {
    MSMomentModel *model = [self.class findFirstByCriteria:[NSString stringWithFormat:@"where moodId=%ld",(long)_moodId]];
    if (!model) {
        return NO;
    }
    return model.loved;
}

+ (NSArray *)transients {
    return @[@"userId",@"commentCount",@"comments",@"greet",@"portraitUrl",@"moodUrl",@"text",@"type",@"nickName",@"videoImg",@"videoUrl"];
}

@end



@implementation MSMomentsModel

- (Class)moodElementClass {
    return [MSMomentModel class];
}

@end
