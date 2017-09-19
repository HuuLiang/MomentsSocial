//
//  MSUserModel.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/5.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSUserModel.h"

static NSString *kMSUserModelUserIdKeyName          = @"MSUserModel_userId_keyName";
static NSString *kMSUserModelPhoneKeyName           = @"MSUserModel_phone_keyName";
static NSString *kMSUserModelSexKeyName             = @"MSUserModel_sex_keyName";
static NSString *kMSUserModelAgeKeyName             = @"MSUserModel_age_keyName";
static NSString *kMSUserModelMaritalKeyName         = @"MSUserModel_marital_keyName";
static NSString *kMSUserModelWeightKeyName          = @"MSUserModel_weight_keyName";
static NSString *kMSUserModelWeixinKeyName          = @"MSUserModel_weixin_keyName";
static NSString *kMSUserModelProtraitUrlKeyName     = @"MSUserModel_protrait_keyName";
static NSString *kMSUserModelIncomeKeyName          = @"MSUserModel_income_keyName";
static NSString *kMSUserModelBirthdayKeyName        = @"MSUserModel_birthday_keyName";
static NSString *kMSUserModelNickNameKeyName        = @"MSUserModel_nickName_keyName";
static NSString *kMSUserModelCityKeyName            = @"MSUserModel_city_keyName";
static NSString *kMSUserModelEducationKeyName       = @"MSUserModel_education_keyName";
static NSString *kMSUserModelQQKeyName              = @"MSUserModel_qq_keyName";
static NSString *kMSUserModelVocationKeyName        = @"MSUserModel_vocation_keyName";
static NSString *kMSUserModelHeightKeyName          = @"MSUserModel_height_keyName";
static NSString *kMSUserModelConstellationKeyName   = @"MSUserModel_constellation_keyName";


@implementation MSUserMsgModel

@end

@implementation MSUserModel

- (Class)userPhotoElementClass {
    return [NSString class];
}

- (Class)messageElementClass {
    return [MSUserMsgModel class];
}

+ (NSArray *)transients {
    return @[@"phone",@"sex",@"age",@"marital",@"weight",@"weixin",@"portraitUrl",@"income",@"birthday",@"nickName",@"city",@"education",@"qq",@"vocation",@"height",@"constellation",@"userPhoto",@"vipLv",@"message"];
//    return @[@"userPhoto",@"vipLv",@"message"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.userId         = [[aDecoder decodeObjectForKey:kMSUserModelUserIdKeyName] integerValue];
        self.phone          = [aDecoder decodeObjectForKey:kMSUserModelPhoneKeyName];
        self.sex            = [aDecoder decodeObjectForKey:kMSUserModelSexKeyName];
        self.age            = [[aDecoder decodeObjectForKey:kMSUserModelAgeKeyName] integerValue];
        self.marital        = [aDecoder decodeObjectForKey:kMSUserModelMaritalKeyName];
        self.weight         = [aDecoder decodeObjectForKey:kMSUserModelWeightKeyName];
        self.weixin         = [aDecoder decodeObjectForKey:kMSUserModelWeixinKeyName];
        self.portraitUrl    = [aDecoder decodeObjectForKey:kMSUserModelProtraitUrlKeyName];
        self.income         = [aDecoder decodeObjectForKey:kMSUserModelIncomeKeyName];
        self.birthday       = [aDecoder decodeObjectForKey:kMSUserModelBirthdayKeyName];
        self.nickName       = [aDecoder decodeObjectForKey:kMSUserModelNickNameKeyName];
        self.city           = [aDecoder decodeObjectForKey:kMSUserModelCityKeyName];
        self.education      = [aDecoder decodeObjectForKey:kMSUserModelEducationKeyName];
        self.qq             = [[aDecoder decodeObjectForKey:kMSUserModelQQKeyName] integerValue];
        self.vocation       = [aDecoder decodeObjectForKey:kMSUserModelVocationKeyName];
        self.height         = [[aDecoder decodeObjectForKey:kMSUserModelHeightKeyName] integerValue];
        self.constellation  = [aDecoder decodeObjectForKey:kMSUserModelConstellationKeyName];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.userId) forKey:kMSUserModelUserIdKeyName];
    [aCoder encodeObject:self.phone forKey:kMSUserModelPhoneKeyName];
    [aCoder encodeObject:self.sex forKey:kMSUserModelSexKeyName];
    [aCoder encodeObject:@(self.age) forKey:kMSUserModelAgeKeyName];
    [aCoder encodeObject:self.marital forKey:kMSUserModelMaritalKeyName];
    [aCoder encodeObject:self.weight forKey:kMSUserModelWeightKeyName];
    [aCoder encodeObject:self.weixin forKey:kMSUserModelWeixinKeyName];
    [aCoder encodeObject:self.portraitUrl forKey:kMSUserModelProtraitUrlKeyName];
    [aCoder encodeObject:self.income forKey:kMSUserModelIncomeKeyName];
    [aCoder encodeObject:self.birthday forKey:kMSUserModelBirthdayKeyName];
    [aCoder encodeObject:self.nickName forKey:kMSUserModelNickNameKeyName];
    [aCoder encodeObject:self.city forKey:kMSUserModelCityKeyName];
    [aCoder encodeObject:self.education forKey:kMSUserModelEducationKeyName];
    [aCoder encodeObject:@(self.qq) forKey:kMSUserModelQQKeyName];
    [aCoder encodeObject:self.vocation forKey:kMSUserModelVocationKeyName];
    [aCoder encodeObject:@(self.height) forKey:kMSUserModelHeightKeyName];
    [aCoder encodeObject:self.constellation forKey:kMSUserModelConstellationKeyName];
}

- (BOOL)isGreeted {
    if (_userId == 10000262) {
        
    }
    MSUserModel *userModel = [MSUserModel findFirstByCriteria:[NSString stringWithFormat:@"where userId=%ld",(long)_userId]];
    if (!userModel) {
        return NO;
    }
    return userModel.greeted;
}

+ (BOOL)isGreetedWithUserId:(NSInteger)userId {
    MSUserModel *userModel = [MSUserModel findFirstByCriteria:[NSString stringWithFormat:@"where userId=%ld",(long)userId]];
    if (!userModel) {
        return NO;
    }
    return userModel.greeted;
}



+ (NSArray *)allUserSex {
    return @[@"",@"男",@"女"];
}

+ (NSArray *)allUserAge {
    NSMutableArray *allAges = [NSMutableArray array];
    for (NSInteger age = 18; age <= 50; age++) {
        NSString *str = [NSString stringWithFormat:@"%ld",(long)age];
        [allAges addObject:str];
    }
    return allAges;
}

+ (NSArray *)allUserWeight {
    NSMutableArray *allWeight = [NSMutableArray array];
    for (NSInteger weight = 40; weight <= 120; weight++) {
        NSString *str = [NSString stringWithFormat:@"%ldkg",(long)weight];
        [allWeight addObject:str];
    }
    return allWeight;
}

+ (NSArray *)allUserStars {
    return @[@"白羊座",@"金牛座",@"双子座",@"巨蟹座",@"狮子座",@"处女座",@"天秤座",@"天蝎座",@"射手座",@"摩羯座",@"水瓶座",@"双鱼座"];
}

+ (NSArray *)allUserJob {
    return @[@"在校学生",@"军人",@"私营业主",@"企业职工",@"农业劳动者",@"政府机关／事业单位工作者",@"其他"];
}

+ (NSArray *)allUserEdu {
    return @[@"初中及以下",@"高中及中专",@"大专",@"本科",@"硕士及以上"];
}

+ (NSArray *)allUserIncome {
    return @[@"小于2000",@"2000-5000",@"5000-10000",@"10000-20000",@"20000以上"];
}

+ (NSArray *)allUserHeight {
    NSMutableArray *allHeights = [NSMutableArray array];
    for (NSInteger height = 150; height <= 190; height++) {
        NSString *str = [NSString stringWithFormat:@"%ld",(long)height];
        [allHeights addObject:str];
    }
    return allHeights;
}

+ (NSArray *)allUserMarr {
    return @[@"未婚",@"已婚",@"离异",@"丧偶"];
}


@end
