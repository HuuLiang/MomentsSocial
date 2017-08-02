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

static NSString *const kRegisterKeyName           = @"MS_register_keyname";

static NSString *const KMSUserVipLevelKeyName     = @"KMSUserVipLevelKeyName";

@implementation MSUtil

#pragma mark -- 注册激活

//+ (NSString *)accessId {
//    NSString *accessIdInKeyChain = [SFHFKeychainUtils getPasswordForUsername:kUserAccessUsername andServiceName:kUserAccessServicename error:nil];
//    if (accessIdInKeyChain) {
//        return accessIdInKeyChain;
//    }
//    
//    accessIdInKeyChain = [NSUUID UUID].UUIDString.md5;
//    [SFHFKeychainUtils storeUsername:kUserAccessUsername andPassword:accessIdInKeyChain forServiceName:kUserAccessServicename updateExisting:YES error:nil];
//    return accessIdInKeyChain;
//}

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
    }else if ([deviceName rangeOfString:@"iPhone9,1"].location == 0){
        return MSDeviceType_iPhone7;
    }else if ([deviceName rangeOfString:@"iPhone9,2"].location == 0){
        return MSDeviceType_iPhone7P;
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


@end