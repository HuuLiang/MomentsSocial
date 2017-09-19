//
//  MSNearCell.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/27.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSNearCell : UITableViewCell

@property (nonatomic) NSString *imgUrl;

@property (nonatomic) NSString *nickName;

@property (nonatomic) NSInteger age;

//@property (nonatomic) NSString *sex;

@property (nonatomic) NSString *location;

@property (nonatomic) BOOL isGreeted;

@property (nonatomic) MSAction greetAction;

@end


//FOUNDATION_EXPORT NSString *const kMSRobotSexMaleKeyName;
//FOUNDATION_EXPORT NSString *const kMSRobotSexFemaleKeyName;
