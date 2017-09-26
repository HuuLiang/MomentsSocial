//
//  MSPopupHelper.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/1.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MSPopupType) {
    MSPopupTypeNone = 0,
    MSPopupTypeChangeUserInfo = 1,
    MSPopupTypeSendMessage = 2,
    MSPopupTypeUserDetailInfo = 3,
    MSPopupTypeRegisterVip0 = 4,
    MSPopupTypeRegisterVip1 = 5,
    MSPopupTypeShakeTime = 6,
    MSPopupTypeCircleVip1 = 7,
    MSPopupTypeCircleVip2 = 8,
    MSPopupTypePostMoment = 9,
    MSPopupTypePhotoVip1 = 10,
    MSPopupTypePhotoVip2 = 11,
    MSPopupTypeVideoVip1 = 12,
    MSPopupTypeVideoVip2 = 13,
    MSPopupTypeFaceTime = 14,
    MSPopupTypeFaceTimeVip1 = 15,
    MSPopupTypeMoreMoments = 16,
    MSPopupTypeSendComment = 17,
    MSPopupTypeBookLuoVip1 = 18,
    MSPopupTypeBookLuoVip2 = 19,
    MSPopupTypeDiscoverHeaderVip = 20,
    MSPopupTypeMineVC = 21,
    MSPopupTypeActivity = 22
};

typedef void(^CancleAction)(void);
typedef void(^ConfirmAction)(void);

@interface MSPopupHelper : NSObject

+ (instancetype)helper;

- (void)showPopupViewWithType:(MSPopupType)type disCount:(BOOL)disCount cancleAction:(CancleAction)cancleAction confirmAction:(ConfirmAction)confirmAction ;

@end


@interface MSPopupView : UIView
- (instancetype)initWithMsg:(NSString *)msg
                   dicCount:(BOOL)disCount
                  cancleMsg:(NSString *)cancleMsg
               cancleAction:(CancleAction)cancleAction
                 confirmMsg:(NSString *)confirmMsg
              confirmAction:(ConfirmAction)confirmAction hideAction:(void(^)(void))hideAction;
@end
