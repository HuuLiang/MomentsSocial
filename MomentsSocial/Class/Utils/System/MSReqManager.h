//
//  MSReqManager.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSReqManager : NSObject

+ (instancetype)manager;

/** 激活 */
- (void)registerUUIDWithCompletionHandler:(MSCompletionHandler)handler;

/** 秘爱 首页 */
- (void)fetchHomeInfoWithCompletionHandler:(MSCompletionHandler)handler;

/** 秘爱 分类圈子 */

@end
