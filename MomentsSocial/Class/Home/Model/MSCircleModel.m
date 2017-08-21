//
//  MSCircleModel.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/3.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSCircleModel.h"

@implementation MSCircleInfo

+ (NSArray *)transients {
    return @[@"circleImg",@"circleDesc",@"name",@"vipLv"];
}

- (NSInteger)numberWithCircleId:(NSInteger)circleId {
    MSCircleInfo * info = [MSCircleInfo findFirstByCriteria:[NSString stringWithFormat:@"where circleId=%ld",circleId]];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    if (!info) {
        info = [[MSCircleInfo alloc] init];
        info.number = arc4random() % 2931 + 92;
        info.time = time;
        info.circleId = circleId;
        [info save];
    } else {
        if (time - info.time > 300) {
            info.number = info.number + [MSUtil getRandomNumber:-60 to:60];
            if (info.number <= 0) {
                info.number = 0;
            }
            info.time = time;
            [info update];
        }
    }
    return info.number;
}

- (Class)titlesElementClass {
    return [NSString class];
}

- (Class)coversElementClass {
    return [NSString class];
}

@end


@implementation MSCircleModel

- (Class)circleElementClass {
    return [MSCircleInfo class];
}

- (Class)hotCircleElementClass {
    return [MSCircleInfo class];
}

@end
