//
//  MSCommonDef.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#ifndef MSCommonDef_h
#define MSCommonDef_h

typedef NS_ENUM(NSUInteger, MSDeviceType) {
    MSDeviceTypeUnknown,
    MSDeviceType_iPhone4,
    MSDeviceType_iPhone4S,
    MSDeviceType_iPhone5,
    MSDeviceType_iPhone5C,
    MSDeviceType_iPhone5S,
    MSDeviceType_iPhone6,
    MSDeviceType_iPhone6P,
    MSDeviceType_iPhone6S,
    MSDeviceType_iPhone6SP,
    MSDeviceType_iPhoneSE,
    MSDeviceType_iPhone7,
    MSDeviceType_iPhone7P,
    MSDeviceType_iPhone8,
    MSDeviceType_iPhone8P,
    MSDeviceType_iPhoneX,
    MSDeviceType_iPad = 100
};

typedef NS_ENUM(NSInteger,MSLevel) {
    MSLevelVip0 = 0 ,//游客
    MSLevelVip1, //vip1
    MSLevelVip2 //vip2
};

typedef NS_ENUM(NSInteger,MSPayType) {
    MSPayTypeWeiXin = 1, //微信
    MSPayTypeAliPay //支付宝
};

typedef NS_ENUM(NSInteger,MSGiftPopViewType) {
    MSGiftPopViewTypeBlag = 0, //索要礼物
    MSGiftPopViewTypeList      //赠送礼物
};

typedef NS_ENUM(NSInteger,MSSocialType) {
    MSSocialTypeAll = 0,
    MSSocialTypeChat,
    MSSocialTypeGame,
    MSSocialTypeGF
};

typedef NS_ENUM(NSInteger, MSMessagePopViewType) {
    MSMessagePopViewTypeVip, // 开通vip界面
    MSMessagePopViewTypeDiamond, //充值钻石列表界面
    MSMessagePopViewTypeBuyDiamond //充值钻石界面
};

typedef NS_ENUM(NSInteger, MSUserInfoOpenType) {
    MSUserInfoOpenTypeClose = 0,//对vip用户开放
    MSUserInfoOpenTypeVip //保密
};

typedef NS_ENUM(NSUInteger, MSMessageType) {
    MSMessageTypeText = 1,          //文字消息
    MSMessageTypePhoto = 2,             //图片消息
    MSMessageTypeVoice = 3,             //声音
    MSMessageTypeVideo = 4,             //视频
    MSMessageTypeFaceTime = 5,          //视频聊天邀请
    MSMessageTypeVipNotice = 6,           //开通VIP提醒
    MSMessageTypeCount
};

typedef NS_ENUM(NSInteger, MSPayResult) {
    MSPayResultUnknow = 0,     //未知状态
    MSPayResultSuccess = 1,    //成功
    MSPayResultCancle = 2,     //取消
    MSPayResultFailed = 3      //失败
};

typedef void (^MSAction)(void);
typedef void (^MSObjectAction)(id obj);
typedef void (^MSCompletionHandler)(BOOL success,id obj);


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wextern-initializer"


//NSString *const kMSUserSexMale = @"男";
//NSString *const kMSUserSexFemale = @"女";


#pragma clang diagnostic pop

static NSString *const kMSFriendCurrentUserKeyName         = @"kMSFriendCurrentUserKeyName";

#define MSOpenVipSuccessNotification      @"MSOpenVipSuccessNotification"

#define kMSPostContactInfoNotification    @"kMSPostContactInfoNotification"
#define kMSPostMessageInfoNotification    @"kMSPostMessageInfoNotification"

#define kMSPostOnlineInfoNotification     @"kMSPostOnlineInfoNotification"

#define kMSAutoNotificationTypeKeyName    @"type"


#define tableViewCellheight  MAX(kScreenHeight*0.06,44)


#define KDateFormatShortest               @"yyyyMMdd"
#define kDateFormatShort                  @"yyyy-MM-dd"
#define kDateFormatChina                  @"yyyy年MM月dd日"
#define KDateFormatLong                   @"yyyyMMddHHmmss"
#define kDateFormateLongest               @"yyyy-MM-dd HH:mm:ss"
#define kBirthDayMinDate                  @"1942-01-01"
#define kBirthDayMaxDate                  @"2017-02-01"
#define KBirthDaySeletedDate              @"2000-01-01"

#define kWidth(width)                     kScreenWidth  * width  / 750.
#define kHeight(height)                   kScreenHeight * height / 1334.
#define kDetailPhotoWidth                 floor((kScreenWidth - kWidth(60))/3)

#define kColor(hexString)                 [UIColor colorWithHexString:[NSString stringWithFormat:@"%@",hexString]]
#define kCurrentUser                      [MSUser currentUser]
#define kFont(font)                       [UIFont systemFontOfSize:kWidth(font*2)]



#endif /* MSCommonDef_h */
