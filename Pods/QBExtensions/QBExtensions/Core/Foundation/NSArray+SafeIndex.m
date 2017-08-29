//
//  NSArray+SafeIndex.m
//  FunTuYing
//
//  Created by Sean Yue on 2017/7/6.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "NSArray+SafeIndex.h"

@implementation NSArray (SafeIndex)

- (id)s_objectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndex:index];
    } else {
        return nil;
    }
}
@end
