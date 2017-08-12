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
    if (!info) {
        info = [[MSCircleInfo alloc] init];
        info.number = self.number;
        info.circleId = circleId;
        [info save];
    } else {
        info.number = info.number + 10 - (arc4random() % 31);
        [info update];
    }
    return info.number;
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
