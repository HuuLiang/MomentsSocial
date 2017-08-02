//
//  MSConfiguration.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSConfiguration : NSObject

@property (nonatomic,readonly) NSString *channelNo;

+ (instancetype)sharedConfig;
+ (instancetype)sharedStandbyConfig;


@end
