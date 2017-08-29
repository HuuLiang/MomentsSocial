//
//  NSArray+Random.m
//  QLive
//
//  Created by Sean Yue on 2017/3/7.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "NSArray+Random.h"

@implementation NSArray (Random)

- (NSArray *)QL_arrayByPickingRandomCount:(NSUInteger)count {
    if (count > self.count) {
        count = self.count;
    }
    
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:count];
    
    NSMutableArray *arr = self.mutableCopy;
    for (NSUInteger i = 0; i < count; ++i) {
        NSUInteger index = arc4random_uniform((uint32_t)arr.count);
        [results addObject:arr[index]];
        [arr removeObjectAtIndex:index];
    }
    return results;
}

- (NSArray *)QL_match:(BOOL (^)(id obj))match {
    NSMutableArray *matchedArray = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (match && match(obj)) {
            [matchedArray addObject:obj];
        }
    }];
    
    return matchedArray.count > 0 ? matchedArray : nil;
}

- (NSArray *)QL_arrayByPickingRandomCount:(NSUInteger)count match:(BOOL (^)(id obj))match {
    NSArray *matchedArray = [self QL_match:match];
    return [matchedArray QL_arrayByPickingRandomCount:count];
}

- (NSArray *)QL_arrayByPickingRandomCount:(NSUInteger)count match:(BOOL (^)(id obj))match afterFilter:(NSArray * (^)(NSArray *array))filter
{
    NSArray *filteredArray = filter(self);
    return [filteredArray QL_arrayByPickingRandomCount:count match:match];
}

@end
