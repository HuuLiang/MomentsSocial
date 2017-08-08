//
//  MSContactCell.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <MGSwipeTableCell.h>

@interface MSContactCell : MGSwipeTableCell
@property (nonatomic) NSString *portraitUrl;
@property (nonatomic) NSString *nickName;
@property (nonatomic) NSTimeInterval msgTime;
@property (nonatomic) NSInteger msgType;
@property (nonatomic) NSString *msgContent;
@property (nonatomic) NSInteger unreadCount;
@property (nonatomic) BOOL isOneline;
@end
