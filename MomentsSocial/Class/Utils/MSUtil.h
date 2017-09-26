//
//  MSUtil.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MSUserModel;
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

+ (MSUserModel *)currentUser;

+ (void)saveCurrentUserInfo:(MSUserModel *)userModel;

+ (void)registerBindPhoneNumber:(NSString *)phoneNumber;
+ (NSString *)getbindingPhoneNumber;



+ (BOOL)isIpad;
+ (NSString *)appVersion;
+ (NSString *)deviceName;
+ (MSDeviceType)deviceType;

+ (void)setVipLevel:(MSLevel)vipLevel;
+ (MSLevel)currentVipLevel;
+ (BOOL)isToday;

+ (void)addCheckLoginCount;
+ (NSInteger)loginDays;

+ (NSString *)compareCurrentTime:(NSTimeInterval)compareTimeInterval;
+ (NSString *)currentTimeStringWithFormat:(NSString *)timeFormat;

+ (UIViewController *)rootViewControlelr;
+ (UIViewController *)currentViewController;

+ (float)getVideoLengthWithVideoUrl:(NSString *)videoUrl;

+ (int)getRandomNumber:(int)fromNumber to:(int)toNubmer;

@end
