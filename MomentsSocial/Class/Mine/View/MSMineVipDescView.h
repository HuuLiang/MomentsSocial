//
//  MSMineVipDescView.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/28.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MSMineVipDescView : UIView

@property (nonatomic) MSAction openVipAction;

@end


@interface MSVipDescView : UIView
- (instancetype)initWithImgName:(NSString *)imgName desc:(NSString *)desc;
@end
