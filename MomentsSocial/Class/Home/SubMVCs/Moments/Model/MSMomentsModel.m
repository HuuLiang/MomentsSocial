//
//  MSMomentsModel.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/31.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMomentsModel.h"

@implementation MSMomentCommentsInfo

@end

@implementation MSMomentModel

- (Class)moodUrlElementClass {
    return [NSString class];
}

- (Class)commentsElementClass {
    return [MSMomentCommentsInfo class];
}

- (BOOL)greeted {
    MSMomentModel *model = [self.class findFirstByCriteria:[NSString stringWithFormat:@"where moodId=%ld",(long)_moodId]];
    return model ? model.greeted : NO;
}

- (BOOL)loved {
    MSMomentModel *model = [self.class findFirstByCriteria:[NSString stringWithFormat:@"where moodId=%ld",(long)_moodId]];
    return model ? model.loved : NO;
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
