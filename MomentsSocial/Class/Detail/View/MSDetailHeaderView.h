//
//  MSDetailHeaderView.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/28.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSDetailHeaderView : UIView

@property (nonatomic) NSString *imgUrl;

@property (nonatomic) NSString *nickName;

@property (nonatomic) BOOL online;

//@property (nonatomic) NSString *location;

@property (nonatomic) MSLevel vipLevel;

@property (nonatomic) MSAction backAction;
@end
