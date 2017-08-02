//
//  MSRegexUtil.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSRegexUtil.h"

@implementation MSRegexUtil
+ (BOOL)isPhoneNumberWithString:(NSString *)string {
    
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|7[0678])\\d{8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    return [regextestmobile evaluateWithObject:string];
}

+ (BOOL)isWechatWithString:(NSString *)string {
    //^[a-zA-Z]{1}[-_a-zA-Z0-9]{5,19}+$
    NSString *wechat = @"^[a-zA-Z]{1}[-_a-zA-Z0-9]{5,19}+$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", wechat];
    return [regextestmobile evaluateWithObject:string];
}

+ (BOOL)isQQWithString:(NSString *)string {
    //[1-9][0-9]{4,}
    NSString *qq = @"[1-9][0-9]{4,10}";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", qq];
    return [regextestmobile evaluateWithObject:string];
}
@end
