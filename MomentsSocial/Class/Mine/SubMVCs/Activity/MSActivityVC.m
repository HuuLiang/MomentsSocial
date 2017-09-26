//
//  MSActivityVC.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/18.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSActivityVC.h"
#import "MSActDescView.h"
#import "MSActFuncView.h"
#import "MSPaymentManager.h"
#import "MSSystemConfigModel.h"
#import "MSVipVC.h"

@interface MSActivityVC ()
@property (nonatomic) UITableView *tableView;
@property (nonatomic) MSActDescView *descView;
@property (nonatomic) MSActFuncView *funcView;
@end

@implementation MSActivityVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = kColor(@"#ffffff");
    [self.view addSubview:_tableView];
    
    {
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    [self configDescView];
    [self configFunctionView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStatus) name:MSOpenVipSuccessNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshStatus {
    BOOL isGoldVipPaid = [[MSPaymentManager manager] checkIsPaidGoldVip];
    if (self.descView) {
        _descView.isGoldVipPaid = isGoldVipPaid;
    }
    
    if (self.funcView) {
        //未购买黄金会员
        if (!isGoldVipPaid) {
            //如果当前vip等级为0 1 则可以参与活动 如果是vip为2 则活动失效
            if ([MSUtil currentVipLevel] < MSLevelVip2) {
                self.funcView.funcType = MSActFuncTypeJoin;
            } else {
                self.funcView.funcType = MSActFuncViewNone;
            }
        } else {
            //购买了黄金会员
            if ([MSUtil getbindingPhoneNumber].length == 0) {
                //没有绑定手机号 提示绑定
                self.funcView.funcType = MSActFuncTypeInput;
            } else {
                //已绑定 显示绑定号码
                self.funcView.funcType = MSActFuncTypeBinding;
            }
        }
    }
}

- (void)configDescView {
    self.descView = [[MSActDescView alloc] init];
    _descView.size = CGSizeMake(kScreenWidth, kWidth(700));
    self.tableView.tableHeaderView = _descView;
    
    @weakify(self);
    [_descView bk_whenTapped:^{
        @strongify(self);
        [self.funcView resignResponder];
    }];
}

- (void)configFunctionView {
    self.funcView = [[MSActFuncView alloc] init];
    _funcView.size = CGSizeMake(kScreenWidth, kWidth(208));
    self.tableView.tableFooterView = _funcView;
    @weakify(self);
    _funcView.joinAction = ^{
        @strongify(self);
        [MSVipVC showVipViewControllerInCurrentVC:self contentType:MSPopupTypeActivity payPoints:@[[MSSystemConfigModel defaultConfig].PAY_VIP_1_1]];
    };
}

@end

