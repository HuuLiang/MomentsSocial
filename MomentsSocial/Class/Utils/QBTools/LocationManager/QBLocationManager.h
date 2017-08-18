//
//  QBLocationManager.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBLocationModel : JKDBModel
@property (nonatomic) NSString *userId;
@property (nonatomic) NSString *locationName;
@property (nonatomic) NSInteger locationTime;
@end


@interface QBLocationManager : NSObject
+ (instancetype)manager;
@property (nonatomic) NSString *currentLocation;
- (BOOL)checkLocationIsEnable;
- (void)loadLocationManager;
- (void)getUserLacationNameWithUserId:(NSString *)userId locationName:(void(^)(BOOL success,NSString *locationName))handler;
@end
