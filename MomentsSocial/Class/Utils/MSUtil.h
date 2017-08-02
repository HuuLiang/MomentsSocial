//
//  MSUtil.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSUtil : NSObject

//+ (NSString *)accessId;

+ (NSString *)UUID;
+ (BOOL)isRegisteredUUID;
+ (void)setRegisteredWithUUID:(NSString *)uuid;

+ (BOOL)isIpad;
+ (NSString *)appVersion;
+ (NSString *)deviceName;
+ (MSDeviceType)deviceType;

+ (void)setVipLevel:(MSLevel)vipLevel;
+ (MSLevel)currentVipLevel;

@end
