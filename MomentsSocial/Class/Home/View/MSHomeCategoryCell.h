//
//  MSHomeCategoryCell.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/27.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSHomeCategoryCell : UICollectionViewCell

@property (nonatomic) MSAction joinAction;

@property (nonatomic) NSString *imgUrl;

@property (nonatomic) NSString *title;

@property (nonatomic) NSString *subTitle;

@property (nonatomic) MSLevel vipLevel;

@end
