//
//  MSCheckInHeaderView.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/3.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSCheckInHeaderView : UICollectionReusableView

@property (nonatomic) NSString *imgUrl;

@property (nonatomic) MSAction registerAction;

@property (nonatomic) BOOL canCheckIn;

@end
