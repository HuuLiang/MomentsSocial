//
//  MSMomentsListCell.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/27.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSMomentsListCell : UITableViewCell
@property (nonatomic) NSString *imgUrl;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *subTitle;
@property (nonatomic) MSLevel vipLevel;
@property (nonatomic) NSInteger count;
@end
