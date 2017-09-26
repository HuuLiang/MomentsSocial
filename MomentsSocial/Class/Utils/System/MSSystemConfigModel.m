//
//  MSSystemConfigModel.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/3.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSSystemConfigModel.h"

NSString *const kMSPayInfoPAY_VIP_1_1KeyName = @"PAY_VIP_1_1";
NSString *const kMSPayInfoPAY_VIP_1_2KeyName = @"PAY_VIP_1_2";
NSString *const kMSPayInfoPAY_VIP_2_1KeyName = @"PAY_VIP_2_1";
NSString *const kMSPayInfoPAY_VIP_2_2KeyName = @"PAY_VIP_2_2";

@implementation MSPayInfo

@end

@implementation MSConfigInfo

@end

@implementation MSSystemConfigModel

+ (instancetype)defaultConfig {
    static MSSystemConfigModel * _configModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _configModel = [[MSSystemConfigModel alloc] init];
    });
    return _configModel;
}

- (Class)configClass {
    return [MSConfigInfo class];
}

- (void)configPayInfoWithConfig:(MSConfigInfo *)config {
    [config.allProperties enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:kMSPayInfoPAY_VIP_1_1KeyName]  || [obj isEqualToString:kMSPayInfoPAY_VIP_1_2KeyName]  || [obj isEqualToString:kMSPayInfoPAY_VIP_2_1KeyName] || [obj isEqualToString:kMSPayInfoPAY_VIP_2_2KeyName]) {
            MSPayInfo *info = nil;
            info = [self setValue:[[MSPayInfo alloc] init] value:[config valueForKey:obj]];
            if ([obj isEqualToString:kMSPayInfoPAY_VIP_1_1KeyName]) {
                [info setValue:@(1) forKey:@"payPointId"];
            } else if ([obj isEqualToString:kMSPayInfoPAY_VIP_1_2KeyName]) {
                [info setValue:@(2) forKey:@"payPointId"];
            } else if ([obj isEqualToString:kMSPayInfoPAY_VIP_2_1KeyName]) {
                [info setValue:@(3) forKey:@"payPointId"];
            } else if ([obj isEqualToString:kMSPayInfoPAY_VIP_2_2KeyName]) {
                [info setValue:@(4) forKey:@"payPointId"];
            }
            [self setValue:info forKey:obj] ;
            
        }
    }];
    
}

- (MSPayInfo *)setValue:(MSPayInfo *)info value:(id)value {
    [[value componentsSeparatedByString:@"|"] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            info.title = obj;
        } else if (idx == 1) {
            info.price = [obj integerValue];
        } else if (idx == 2) {
            info.days = [obj integerValue];
        } else if (idx == 3) {
            info.subTitle = obj;
        } else if (idx == 4) {
            info.desc = obj;
        }
    }];
    return info;
}

@end
