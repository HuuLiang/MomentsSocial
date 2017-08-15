//
//  MSMomentsCell.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/31.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , MSMomentsType) {
    MSMomentsTypePhotos = 1,
    MSMomentsTypeVideo
};

@interface MSMomentsCell : UITableViewCell

@property (nonatomic) MSAction detailAction;

@property (nonatomic) MSAction commentAction;

@property (nonatomic) MSAction greetAction;

@property (nonatomic) MSAction loveAction;

@property (nonatomic) MSObjectAction photoAction;

@property (nonatomic) MSAction VideoAction;

@property (nonatomic) NSString *userImgUrl;

@property (nonatomic) NSString *nickName;

@property (nonatomic) NSNumber * online;

@property (nonatomic) NSString *content;

@property (nonatomic) NSString *location;

@property (nonatomic) NSNumber * commentsCount;

@property (nonatomic) NSNumber * attentionCount;

@property (nonatomic) MSMomentsType momentsType;

@property (nonatomic) NSNumber * greeted;

@property (nonatomic) NSNumber * loved;

@property (nonatomic) MSLevel vipLv;

@property (nonatomic) id dataSource;

@property (nonatomic) NSString *nickA;
@property (nonatomic) NSString *commentA;
@property (nonatomic) NSString *nickB;
@property (nonatomic) NSString *commentB;

@end
