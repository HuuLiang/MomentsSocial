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
#define MS_PAYMENT_PV               @"105"
#define MS_CONTENT_VERSION          @"1.0"
#define MS_PACKAGE_CERTIFICATE      @"iPhone Distribution: Neijiang Fenghuang Enterprise (Group) Co., Ltd."

#define MS_REST_APP_VERSION         ((NSString *)([NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]))
#define MS_BUNDLE_IDENTIFIER        ((NSString *)([NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"]))
#define MS_PAYMENT_RESERVE_DATA     [NSString stringWithFormat:@"%@$%@", MS_REST_APPID, MS_CHANNEL_NO]
#define MS_PAYMENT_ORDERID          [NSString stringWithFormat:@"%@_%@", [MS_CHANNEL_NO substringFromIndex:MS_CHANNEL_NO.length-14], [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)]]

#define MS_BASE_URL                    @"http://cfc.shinehoo.com.cn"//@"http://120.24.252.114:8095"//@"http://fr.shinehoo.com.cn"
#define MS_STANDBY_BASE_URL            @"http://sfs.dswtg.com"

#define MS_ACTIVATION_URL              @"/cfc/activat.htm"                            //激活
#define MS_SYSTEMCONFIG_URL            @"/cfc/config.htm"                             //系统配置
#define MS_USER_URL                    @"/cfc/user.htm"                               //查询用户详情
#define MS_HOME_URL                    @"/cfc/queryCircle.htm"                        //圈子
#define MS_MOMENTS_URL                 @"/cfc/queryMood.htm"                          //动态
#define MS_PUSHUSER_URL                @"/cfc/pushUser.htm"                           //批量推送用户
#define MS_PUSHUSERONE_URL             @"/cfc/pushUserOne.htm"                            //单个推送用户
#define MS_DAYHOUSE_URL                @"/cfc/dayHouse.htm"                           //今日开房
#define MS_NEARSHAKE_URL               @"/cfc/nearbyShake.htm"                        //附近的人  摇一摇
#define MS_DISCOVER_URL                @"/cfc/find.htm"                               //发现
#define MS_COMMENT_URL                 @"/cfc/comment.htm"                            //评论列表 
#define MS_LIKES_URL                   @"/cfc/likes.htm"                              //点赞
#define MS_SENDMSG_URL                 @"/cfc/userMessage.htm"                        //发送消息

#define MS_ACTIVITY_URL                @"http://cfc.shinehoo.com.cn/cfc/huodongshuoming.html" //活动相关
#define MS_ABOUTUS_URL                 @"http://cfc.shinehoo.com.cn/cfc/guanyuwomen.html" //关于我们

#define MS_ENCRYPT_PASSWORD            @"qb%Fr@2016_&"

#define MS_AliPay_SchemeUrl            @"commomentssocialschemeurl"

#define MS_UMENG_APP_ID                @"59899d25bbea834cb6000af9"
#define MS_UMENG_STARTPAY_EVENT        @"Start_Pay_Event"
#define MS_UMENG_RESULTPAY_EVENT       @"Result_Pay_Event"
#define MS_UMENG_MONEY_EVENT           @"Pay_Money_Count"

#define MS_TURING_URL                  @"http://www.tuling123.com/openapi/api"
#define MS_TULING_KEY                  @"65d7eee8b5c240dea353533271a3b9eb"

#define MS_QINGYUNKE_URL               @"http://api.qingyunke.com/api.php?key=free&appid=0&msg="

#define MS_WEXIN_APP_ID                @"wx2b2846687e296e95"
#define MS_WECHAT_TOKEN                @"https://api.weixin.qq.com/sns/oauth2/access_token?"
#define MS_WECHAT_SECRET               @"0a4e146c0c399b706514f22ad2f1e078"
#define MS_WECHAT_USERINFO             @"https://api.weixin.qq.com/sns/userinfo?"

#define MS_UPLOAD_SCOPE                @"mfw-image"
#define MS_UPLOAD_SECRET_KEY           @"9mmo2Dd9oca-2SJ5Uou9qQ1d2XjNIoX9EdrPQ6Xj"
#define MS_UPLOAD_ACCESS_KEY           @"JIWlLAM3_bGrfTyU16XKjluzYKcsHOB--yDFB4zt"



#endif /* MSConfig_h */
