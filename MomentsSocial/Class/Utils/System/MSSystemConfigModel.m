//
//  MSSystemConfigModel.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/3.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSSystemConfigModel.h"

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

@end
