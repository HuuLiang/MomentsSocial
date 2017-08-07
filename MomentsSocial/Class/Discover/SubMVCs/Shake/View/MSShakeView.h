//
//  MSShakeView.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/1.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,MSShakeStatus) {
    MSShakeStatusStart = 0, //开始摇一摇
    MSShakeStatusEnd,       //结束
    MSShakeStatusCancle     //取消
};

@interface MSShakeView : UIView

@property (nonatomic) MSShakeStatus shakeStatus;

//@property (nonatomic) MSAction startFetchAction;

@end
