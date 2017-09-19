//
//  MSUserModel.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/5.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "JKDBModel.h"

@interface MSUserMsgModel : NSObject
@property (nonatomic) NSInteger msgId;
@property (nonatomic) MSMessageType msgType;
@property (nonatomic) NSString *content;
@property (nonatomic) NSString *photoUrl;
@property (nonatomic) NSString *voiceUrl;
@property (nonatomic) NSString *videoImg;
@property (nonatomic) NSString *videoUrl;
@end

@interface MSUserModel : JKDBModel <NSCoding>
@property (nonatomic) NSString *phone;
@property (nonatomic) NSString *sex;
@property (nonatomic) NSInteger age;
@property (nonatomic) NSString *marital;
@property (nonatomic) NSString *weight;
@property (nonatomic) NSString *weixin;
@property (nonatomic) NSString *portraitUrl;
@property (nonatomic) NSInteger userId;
@property (nonatomic) NSString *income;
@property (nonatomic) NSString *birthday;
@property (nonatomic) NSString *nickName;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *education;
@property (nonatomic) NSInteger qq;
@property (nonatomic) NSString *vocation;
@property (nonatomic) NSInteger height;
@property (nonatomic) NSString *constellation;
@property (nonatomic) NSArray *userPhoto;
@property (nonatomic) MSLevel vipLv;
@property (nonatomic) BOOL greeted;
@property (nonatomic) NSArray <MSUserMsgModel *> *message;


- (BOOL)isGreeted;

+ (BOOL)isGreetedWithUserId:(NSInteger)userId;


+ (NSArray *)allUserSex;
+ (NSArray *)allUserAge;
+ (NSArray *)allUserWeight;
+ (NSArray *)allUserStars;

//职业
+ (NSArray *)allUserJob;
//学历
+ (NSArray *)allUserEdu;
//收入
+ (NSArray *)allUserIncome;
//身高
+ (NSArray *)allUserHeight;
//婚姻状况
+ (NSArray *)allUserMarr;



@end
