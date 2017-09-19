//
//  MSTuRingManager.h
//  MomentsSocial
//
//  Created by Liang on 2017/9/15.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSTuRingManager : NSObject

+ (instancetype)manager;

- (void)sendMsgToQinYunKe:(NSString *)msgContent userId:(NSInteger)userId handler:(void (^)(NSString *))handler;

//- (void)sendMsgToTuRing:(NSString *)msgContent userId:(NSInteger)userId handler:(void(^)(NSString *msg))handler;
@end
