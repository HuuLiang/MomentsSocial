//
//  MSBaseViewController.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSBaseViewController.h"
#import "MSDetailViewController.h"

@interface MSBaseViewController ()

@end

@implementation MSBaseViewController

- (instancetype)initWithTitle:(NSString *)title {
    self = [self init];
    if (self) {
        self.title = title;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.view.backgroundColor = kColor(@"#ffffff");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)pushIntoDetailVCWithUserId:(NSString *)userId {
    MSDetailViewController *detailVC = [[MSDetailViewController alloc] initWithUserId:userId];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)dealloc {
    NSLog(@"✅✅✅✅ %@  dealloc  🤘🎃✌️",NSStringFromClass(self.class));
}

@end
