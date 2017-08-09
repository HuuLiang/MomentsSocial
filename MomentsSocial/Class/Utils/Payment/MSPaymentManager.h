//
//  MSPaymentManager.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^PayResult)(BOOL success);

@interface MSPaymentManager : NSObject

+ (instancetype)manager;

- (void)startPayForVipLevel:(MSLevel)vipLevel type:(MSPayType)payType  price:(NSInteger)price handler:(PayResult)handler;

@end