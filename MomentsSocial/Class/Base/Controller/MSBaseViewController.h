//
//  MSBaseViewController.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSBaseViewController : UIViewController

@property (nonatomic) BOOL alwaysHideNavigationBar;

- (instancetype)initWithTitle:(NSString *)title;


- (void)pushIntoDetailVCWithUserId:(NSString *)userId;

@end
