//
//  MSMomentsContentView.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/31.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSMomentsContentView : UICollectionView
@property (nonatomic) MSObjectAction browserAction;
@property (nonatomic) MSLevel vipLevel;
@property (nonatomic) NSArray *dataArr;

@end




@interface MSMomentsContentCell : UICollectionViewCell
@property (nonatomic) BOOL needBlur;
@property (nonatomic) NSString *imgUrl;
@end
