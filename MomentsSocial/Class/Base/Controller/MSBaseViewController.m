//
//  MSBaseViewController.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSBaseViewController.h"

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
    self.view.backgroundColor = kColor(@"#ffffff");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




@end
