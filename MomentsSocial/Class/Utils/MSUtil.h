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

+ (void)registerUserId:(NSInteger)userId;
+ (NSInteger)currentUserId;

+ (void)registerNickName:(NSString *)nickName;
+ (NSString *)currentNickName;

+ (void)registerPortraitUrl:(NSString *)portraitUrl;
+ (NSString *)currentProtraitUrl;

+ (BOOL)isIpad;
+ (NSString *)appVersion;
+ (NSString *)deviceName;
+ (MSDeviceType)deviceType;

+ (void)setVipLevel:(MSLevel)vipLevel;
+ (MSLevel)currentVipLevel;
+ (BOOL)isToday;

+ (NSString *)compareCurrentTime:(NSTimeInterval)compareTimeInterval;
+ (NSString *)currentTimeStringWithFormat:(NSString *)timeFormat;

+ (UIViewController *)rootViewControlelr;
+ (UIViewController *)currentViewController;

+ (float)getVideoLengthWithVideoUrl:(NSString *)videoUrl;

+ (int)getRandomNumber:(int)fromNumber to:(int)toNubmer;

@end
