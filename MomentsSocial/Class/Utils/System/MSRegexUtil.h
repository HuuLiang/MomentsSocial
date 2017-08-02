//
//  MSRegexUtil.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSRegexUtil : NSObject
+ (BOOL)isQQWithString:(NSString *)string;
+ (BOOL)isWechatWithString:(NSString *)string;
+ (BOOL)isPhoneNumberWithString:(NSString *)string;
@end
