//
//  MSSendMomentHeaderView.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/2.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSSendMomentHeaderView : UIView

@property (nonatomic) MSAction getPhotoAction;

@property (nonatomic) UIImage *addImg;

@property (nonatomic) NSInteger photoCount;

@property (nonatomic) NSString *location;

@end


@interface MSSendMomentCell : UICollectionViewCell

@property (nonatomic) UIImage *img;;

@end
