//
//  NSArray+SafeIndex.h
//  FunTuYing
//
//  Created by Sean Yue on 2017/7/6.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray<__covariant ObjectType> (SafeIndex)

- (ObjectType)s_objectAtIndex:(NSUInteger)index;

@end
