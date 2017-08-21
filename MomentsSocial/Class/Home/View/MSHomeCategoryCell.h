//
//  MSHomeCategoryCell.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/27.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,MSCircleType) {
    MSCircleTypeNone = 1,
    MSCircleTypeBlur,
    MSCircleTypeCover,
    MSCircleTypeScroll
};

@interface MSHomeCategoryCell : UICollectionViewCell

@property (nonatomic) MSCircleType circleType;

@property (nonatomic) MSLevel vipLevel;

@property (nonatomic) NSString *title;

@property (nonatomic) NSArray *titles;

@property (nonatomic) NSString *backUrl;

@property (nonatomic) NSString *coverImgUrl;

@property (nonatomic) NSArray *imgsUrl;

@end
