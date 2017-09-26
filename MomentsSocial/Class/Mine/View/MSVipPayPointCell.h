//
//  MSVipPayPointCell.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/14.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSPayInfo;

@interface MSVipPayPointCell : UITableViewCell

@property (nonatomic) NSInteger payPointLevel;
@property (nonatomic) MSPayInfo *payPoint;

@property (nonatomic,readonly) NSInteger price;

@end
