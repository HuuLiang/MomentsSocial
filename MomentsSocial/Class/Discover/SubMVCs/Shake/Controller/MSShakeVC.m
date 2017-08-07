//
//  MSShakeVC.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/1.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSShakeVC.h"
#import "MSShakeView.h"
#import "MSShakeUserView.h"
#import "MSReqManager.h"
#import "MSDisFuctionModel.h"

@interface MSShakeVC ()
@property (nonatomic) MSShakeView *shakeView;
@property (nonatomic) MSShakeUserView *userView;
@property (nonatomic) MSUserModel *user;
@end

@implementation MSShakeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kColor(@"#2C2E30");
    
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

    self.shakeView = [[MSShakeView alloc] init];
    [self.view addSubview:_shakeView];
    
//    @weakify(self);
//    _shakeView.startFetchAction = ^{
//        @strongify(self);
//    };
    
    {
        [_shakeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(kWidth(100), kWidth(400)));
        }];
    }
}

- (void)configUserView {
    
    self.userView = [[MSShakeUserView alloc] init];
    _userView.age = self.user.age;
    [self.view addSubview:_userView];
    
    @weakify(self);
    _userView.hateAction = ^{
        @strongify(self);
        if (self.userView) {
            [self.userView removeFromSuperview];
            self.userView = nil;
        }
        [self configShakeView];
    };
    
    _userView.loveAction = ^{
        @strongify(self);
        //喜欢逻辑
    };
    
    {
        [_userView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(kWidth(300), kWidth(400)));
        }];
    }
}

- (void)fetchShakeUserInfo {
    @weakify(self);
    [[MSReqManager manager] fetchNearShakeInfoWithNumber:1 Class:[MSDisFuctionModel class] completionHandler:^(BOOL success, MSDisFuctionModel * obj) {
        @strongify(self);
        if (_shakeView) {
            _shakeView.shakeStatus = MSShakeStatusEnd;
        }
        if (success) {
            if (obj.users.count > 0) {
                self.user = [obj.users firstObject];
                if ([self.view.subviews containsObject:_shakeView]) {
                    //_shakeView移除动画
                    if (_shakeView) {
                        [_shakeView removeFromSuperview];
                        _shakeView = nil;
                    }
                    [self configUserView];
                }
            }
        }
    }];
}

#pragma mark - Motion

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (_shakeView) {
        _shakeView.shakeStatus = MSShakeStatusStart;
        
        [self performSelector:@selector(fetchShakeUserInfo) withObject:nil afterDelay:1.5];
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (_shakeView) {
        
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
