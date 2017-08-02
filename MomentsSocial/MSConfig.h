//
//  MSConfig.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#ifndef MSConfig_h
#define MSConfig_h


#define MS_CHANNEL_NO               [MSConfiguration sharedConfig].channelNo
#define MS_REST_APPID               @"QUBA_2029"
#define MS_REST_PV                  @"100"
#define MS_PAYMENT_PV               @"100"
#define MS_PACKAGE_CERTIFICATE      @"iPhone Distribution: Neijiang Fenghuang Enterprise (Group) Co., Ltd."

#define MS_REST_APP_VERSION         ((NSString *)([NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]))
#define MS_BUNDLE_IDENTIFIER        ((NSString *)([NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"]))
#define MS_PAYMENT_RESERVE_DATA     [NSString stringWithFormat:@"%@$%@", MS_REST_APPID, MS_CHANNEL_NO]
#define MS_PAYMENT_ORDERID          [NSString stringWithFormat:@"%@_%@", [MS_CHANNEL_NO substringFromIndex:MS_CHANNEL_NO.length-14], [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)]]

#define MS_BASE_URL                    @"http://fr.shinehoo.com.cn"
#define MS_STANDBY_BASE_URL            @"http://sfs.dswtg.com"

#define MS_ACTIVATION_URL              @"/flbc/activat.htm"                            //激活

#define MS_HOME_URL                    @""                                             //秘爱 首页


#define MS_ENCRYPT_PASSWORD            @"qb%Fr@2016_&"



#define MS_UMENG_APP_ID                @"5914208be88bad6c13000e6e"
#define MS_QQ_APP_ID                   @""

#define MS_WEXIN_APP_ID                @"wx2b2846687e296e95"
#define MS_WECHAT_TOKEN                @"https://api.weixin.qq.com/sns/oauth2/access_token?"
#define MS_WECHAT_SECRET               @"0a4e146c0c399b706514f22ad2f1e078"
#define MS_WECHAT_USERINFO             @"https://api.weixin.qq.com/sns/userinfo?"

#define MS_UPLOAD_SCOPE                @"mfw-image"
#define MS_UPLOAD_SECRET_KEY           @"9mmo2Dd9oca-2SJ5Uou9qQ1d2XjNIoX9EdrPQ6Xj"
#define MS_UPLOAD_ACCESS_KEY           @"JIWlLAM3_bGrfTyU16XKjluzYKcsHOB--yDFB4zt"



#endif /* MSConfig_h */
