//
//  MSUtil.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSUtil.h"
#import <SFHFKeychainUtils.h>
#import <sys/sysctl.h>
#import <AVFoundation/AVFoundation.h>
#import <QBPaymentInfo.h>

static NSString *const kRegisterKeyName           = @"MS_register_keyname";

static NSString *const KMSUserVipLevelKeyName     = @"KMSUserVipLevelKeyName";

static NSString *const kMSCurrentUserKeyName      = @"kMSCurrentUserKeyName";
static NSString *const kMSUserIdKeyName           = @"kMSUserIdKeyName";
static NSString *const kMSUserNickKeyName         = @"kMSUserNickKeyName";
static NSString *const kMSUserPortraitUrlKeyName  = @"kMSUserPortraitUrlKeyName";

static NSString *const kMSUserBindingPhoneKeyName = @"kMSUserBindingPhoneKeyName";

static NSString *const kMSUserBindMonthKeyName    = @"kMSUserBindMonthKeyName";
static NSString *const kMSUserLoginDaysKeyName    = @"kMSUserLoginDaysKeyName";

static NSString *const kMSAutoReplyMessageTimeRecordKeyName = @"kMSAutoReplyMessageTimeRecordKeyName";

@implementation MSUtil

#pragma mark -- 注册激活

//设备激活
+ (NSString *)UUID {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kRegisterKeyName];
}

+ (BOOL)isRegisteredUUID {
    return [self UUID] != nil;
}

+ (void)setRegisteredWithUUID:(NSString *)uuid {
    [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:kRegisterKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - user
+ (void)registerUserId:(NSInteger)userId {
    MSUserModel *userModel = [self currentUser];
    userModel.userId = userId;
    [self saveCurrentUserInfo:userModel];
}

+ (NSInteger)currentUserId {
    return [self currentUser].userId;
}

+ (void)registerNickName:(NSString *)nickName {
    MSUserModel *userModel = [self currentUser];
    userModel.nickName = nickName;
    [self saveCurrentUserInfo:userModel];
}
+ (NSString *)currentNickName {
    return [self currentUser].nickName;
}

+ (void)registerPortraitUrl:(NSString *)portraitUrl {
    MSUserModel *userModel = [self currentUser];
    userModel.portraitUrl = portraitUrl;
    [self saveCurrentUserInfo:userModel];
}

+ (NSString *)currentProtraitUrl {
    return [self currentUser].portraitUrl;
}

+ (MSUserModel *)currentUser {
    NSData *userData = [[NSUserDefaults standardUserDefaults] objectForKey:kMSCurrentUserKeyName];
    if (!userData) {
        MSUserModel *userModel = [[MSUserModel alloc] init];
        [self saveCurrentUserInfo:userModel];
        return userModel;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:userData];
}

+ (void)saveCurrentUserInfo:(MSUserModel *)userModel {
    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:userModel];
    [[NSUserDefaults standardUserDefaults] setObject:userData forKey:kMSCurrentUserKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)registerBindPhoneNumber:(NSString *)phoneNumber {
    [[NSUserDefaults standardUserDefaults] setObject:phoneNumber forKey:kMSUserBindingPhoneKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getbindingPhoneNumber {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kMSUserBindingPhoneKeyName];
}


#pragma mark - 设备类型

+ (BOOL)isIpad {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

+ (NSString *)appVersion {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
}

+ (NSString *)deviceName {
    size_t size;
    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *name = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return name;
}

+ (MSDeviceType)deviceType {
    NSString *deviceName = [self deviceName];
    if ([deviceName rangeOfString:@"iPhone3,"].location == 0) {
        return MSDeviceType_iPhone4;
    } else if ([deviceName rangeOfString:@"iPhone4,"].location == 0) {
        return MSDeviceType_iPhone4S;
    } else if ([deviceName rangeOfString:@"iPhone5,1"].location == 0 || [deviceName rangeOfString:@"iPhone5,2"].location == 0) {
        return MSDeviceType_iPhone5;
    } else if ([deviceName rangeOfString:@"iPhone5,3"].location == 0 || [deviceName rangeOfString:@"iPhone5,4"].location == 0) {
        return MSDeviceType_iPhone5C;
    } else if ([deviceName rangeOfString:@"iPhone6,"].location == 0) {
        return MSDeviceType_iPhone5S;
    } else if ([deviceName rangeOfString:@"iPhone7,1"].location == 0) {
        return MSDeviceType_iPhone6P;
    } else if ([deviceName rangeOfString:@"iPhone7,2"].location == 0) {
        return MSDeviceType_iPhone6;
    } else if ([deviceName rangeOfString:@"iPhone8,1"].location == 0) {
        return MSDeviceType_iPhone6S;
    } else if ([deviceName rangeOfString:@"iPhone8,2"].location == 0) {
        return MSDeviceType_iPhone6SP;
    } else if ([deviceName rangeOfString:@"iPhone8,4"].location == 0) {
        return MSDeviceType_iPhoneSE;
    } else if ([deviceName rangeOfString:@"iPhone9,1"].location == 0){
        return MSDeviceType_iPhone7;
    } else if ([deviceName rangeOfString:@"iPhone9,2"].location == 0){
        return MSDeviceType_iPhone7P;
    } else if ([deviceName rangeOfString:@"iPhone10,1"].location == 0) {
        return MSDeviceType_iPhone8;
    } else if ([deviceName rangeOfString:@"iPhone10,2"].location == 0) {
        return MSDeviceType_iPhone8P;
    } else if ([deviceName rangeOfString:@"iPhone10,3"].location == 0) {
        return MSDeviceType_iPhoneX;
    } else if ([deviceName rangeOfString:@"iPad"].location == 0) {
        return MSDeviceType_iPad;
    } else {
        return MSDeviceTypeUnknown;
    }
}

#pragma mark - VIP

+ (void)setVipLevel:(MSLevel)vipLevel {
    [[NSUserDefaults standardUserDefaults] setObject:@(vipLevel) forKey:KMSUserVipLevelKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (MSLevel)currentVipLevel {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:KMSUserVipLevelKeyName] integerValue];
}

+ (BOOL)isToday {
    NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:kMSAutoReplyMessageTimeRecordKeyName];
    if (!lastDate) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kMSAutoReplyMessageTimeRecordKeyName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    
    if ([lastDate isToday]) {
        return YES;
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kMSAutoReplyMessageTimeRecordKeyName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return NO;
    }
}

+ (BOOL)thisMonth {
    NSDate *lastMonth = [[NSUserDefaults standardUserDefaults] objectForKey:kMSUserBindMonthKeyName];
    if (!lastMonth) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kMSUserBindMonthKeyName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    
    if ([lastMonth isThisMonth]) {
        return YES;
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kMSUserBindMonthKeyName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return NO;
    }
}

+ (void)addCheckLoginCount {
    __block QBPaymentInfo *info = nil;
    [[QBPaymentInfo allPaymentInfos] enumerateObjectsUsingBlock:^(QBPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.paymentResult == QBPayResultSuccess && [obj.contentId isEqual:@(1)]) {
            info = obj;
            *stop = YES;
        }
    }];
    if (info) {
        NSDate *payGoldDate = [self dateFromString:info.paymentTime WithDateFormat:@"yyyyMMddHHmmss"];
        NSDate *currentDate = [NSDate date];
        if (currentDate.year > payGoldDate.year || currentDate.month > payGoldDate.month) {
            NSInteger loginDays = [self loginDays];
            if ([self thisMonth]) {
                loginDays++;
            } else {
                loginDays = 0;
            }
            [[NSUserDefaults standardUserDefaults] setObject:@(loginDays) forKey:kMSUserLoginDaysKeyName];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } else {
        return;
    }
}

+ (NSInteger)loginDays {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kMSUserLoginDaysKeyName] integerValue];
}

#pragma mark - 时间转换
+ (NSString *)compareCurrentTime:(NSTimeInterval)compareTimeInterval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:compareTimeInterval];
    
    NSTimeInterval  timeInterval = [date timeIntervalSinceNow];
    
    timeInterval = -timeInterval;
    long temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"刚刚"];
    }
    else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%ld分前",temp];
    }
    
    else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%ld小时前",temp];
    }
    
    else if((temp = temp/24) <30){
        result = [NSString stringWithFormat:@"%ld天前",temp];
    }
    
    else if((temp = temp/30) <12){
        result = [NSString stringWithFormat:@"%ld月前",temp];
    }
    else{
        temp = temp/12;
        result = [NSString stringWithFormat:@"%ld年前",temp];
    }
    
    return  result;
}

+ (NSString *)currentTimeStringWithFormat:(NSString *)timeFormat {
    NSDateFormatter *fomatter =[[NSDateFormatter alloc] init];
    [fomatter setDateFormat:timeFormat];
    return [fomatter stringFromDate:[NSDate date]];
}

+ (NSDate *)dateFromString:(NSString *)dateString WithDateFormat:(NSString *)dateFormat {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    return [dateFormatter dateFromString:dateString];
}


#pragma mark - 获取currentVC

+ (UIViewController *)rootViewControlelr {
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

+ (UIViewController *)currentViewController {
    UIViewController* currentVC = [self rootViewControlelr];
    while (1) {
        if ([currentVC isKindOfClass:[UITabBarController class]]) {
            currentVC = ((UITabBarController*)currentVC).selectedViewController;
        }
        
        if ([currentVC isKindOfClass:[UINavigationController class]]) {
            currentVC = ((UINavigationController*)currentVC).visibleViewController;
        }
        
        if (currentVC.presentedViewController) {
            currentVC = currentVC.presentedViewController;
        }else{
            break;
        }
    }
    return currentVC;
}

#pragma mark 获取视频的播放时长
+ (float)getVideoLengthWithVideoUrl:(NSString *)videoUrl {
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoUrl] options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    return audioDurationSeconds;
}

#pragma mark 随机数
+ (int)getRandomNumber:(int)fromNumber to:(int)toNubmer
{
    return (int)(fromNumber + (arc4random() % (toNubmer - fromNumber + 1)));
}

@end
