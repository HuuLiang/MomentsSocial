//
//  MSVipVC.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/14.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSBaseViewController.h"

@class MSPayInfo;

@interface MSVipVC : MSBaseViewController

+ (void)showVipViewControllerInCurrentVC:(UIViewController *)currentViewController contentType:(MSPopupType)contentType;

+ (void)showVipViewControllerInCurrentVC:(UIViewController *)currentViewController contentType:(MSPopupType)contentType payPoints:( NSArray <MSPayInfo *> *)payPoints;

@end
