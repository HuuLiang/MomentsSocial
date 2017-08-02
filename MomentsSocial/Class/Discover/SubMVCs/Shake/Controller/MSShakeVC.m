//
//  MSShakeVC.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/1.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSShakeVC.h"
#import "MSShakeView.h"

@interface MSShakeVC ()
@property (nonatomic) MSShakeView *shakeView;
@end

@implementation MSShakeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kColor(@"#000000");
    
    [self configShakeView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self resignFirstResponder];
}

- (void)configShakeView {
    if (!_shakeView) {
        self.shakeView = [[MSShakeView alloc] init];
        [self.view addSubview:_shakeView];
        {
            [_shakeView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.view);
                make.size.mas_equalTo(CGSizeMake(kWidth(100), kWidth(400)));
            }];
        }
    }
    
}

#pragma mark - Motion

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (_shakeView) {
        _shakeView.shakeStatus = MSShakeStatusStart;
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (_shakeView) {
        _shakeView.shakeStatus = MSShakeStatusEnd;
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (_shakeView) {
        [_shakeView removeFromSuperview];
        _shakeView = nil;
        [self configShakeView];
    }
}

@end
