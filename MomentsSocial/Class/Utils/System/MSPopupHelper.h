//
//  MSPopupHelper.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/1.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MSPopupType) {
    MSPopupTypePhoto = 0,
    MSPopupTypePostMsg
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
