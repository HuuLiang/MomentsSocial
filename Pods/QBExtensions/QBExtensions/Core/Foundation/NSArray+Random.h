//
//  NSArray+Random.h
//  QLive
//
//  Created by Sean Yue on 2017/3/7.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Random)

- (NSArray *)QL_arrayByPickingRandomCount:(NSUInteger)count;
- (NSArray *)QL_arrayByPickingRandomCount:(NSUInteger)count match:(BOOL (^)(id obj))match;
- (NSArray *)QL_arrayByPickingRandomCount:(NSUInteger)count
                                    match:(BOOL (^)(id obj))match
                              afterFilter:(NSArray * (^)(NSArray *array))filter;

@end
