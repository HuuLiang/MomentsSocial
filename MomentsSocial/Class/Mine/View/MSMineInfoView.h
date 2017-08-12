//
//  MSMineInfoView.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/28.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSMineInfoView : UIView

@property (nonatomic) NSString *imgUrl;

@property (nonatomic) NSString *nickName;

@property (nonatomic) MSLevel vipLevel;

@property (nonatomic) NSInteger userId;

@property (nonatomic) MSAction changeImgAction;

@property (nonatomic) MSAction changeNickAction;

@end
