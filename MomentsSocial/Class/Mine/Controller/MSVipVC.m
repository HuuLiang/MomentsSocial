//
//  MSVipVC.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/14.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSVipVC.h"
#import "MSVipPayPointCell.h"
#import "MSPaymentManager.h"

static NSString *const kMSVipPayPointCellReusableIdentifier = @"kMSVipPayPointCellReusableIdentifier";

@interface MSVipVC () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSInteger price;
@end

@implementation MSVipVC

+ (void)showVipViewControllerInCurrentVC:(UIViewController *)currentViewController {
    MSVipVC *vipVC = [[MSVipVC alloc] init];
    [vipVC showVipVCInCurrentVC:currentViewController];
}

- (void)showVipVCInCurrentVC:(UIViewController *)currentVC {
    BOOL anySpreadBanner = [currentVC.childViewControllers bk_any:^BOOL(id obj) {
        if ([obj isKindOfClass:[self class]]) {
            return YES;
        }
        return NO;
    }];
    
    if (anySpreadBanner) {
        return ;
    }
    
    if ([currentVC.view.subviews containsObject:self.view]) {
        return ;
    }
    
    [currentVC addChildViewController:self];
    self.view.frame = currentVC.view.bounds;
    self.view.alpha = 0;
    [currentVC.view addSubview:self.view];
    [self didMoveToParentViewController:currentVC];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 1;
    }];
}

- (void)hide {
    if (!self.view.superview) {
        return ;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [kColor(@"#000000") colorWithAlphaComponent:0.45];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = [kColor(@"#ffffff") colorWithAlphaComponent:0];;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[MSVipPayPointCell class] forCellReuseIdentifier:kMSVipPayPointCellReusableIdentifier];
    [self.view addSubview:_tableView];
    
    {
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(kWidth(610), kWidth(820)));
        }];
    }
    
    [self configTableHeaderView];
    [self configTableFooterView];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)configTableHeaderView {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [kColor(@"#ffffff") colorWithAlphaComponent:0];
    headerView.size = CGSizeMake(kWidth(610), kWidth(312));
    self.tableView.tableHeaderView = headerView;
    
    UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pay_back"]];
    [headerView addSubview:imgV];
    
    UIImageView *closeImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pay_close"]];
    closeImgV.userInteractionEnabled = YES;
    [headerView addSubview:closeImgV];
    
    @weakify(self);
    [closeImgV bk_whenTapped:^{
        @strongify(self);
        [self hide];
    }];
    
    {
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.bottom.equalTo(headerView);
            make.size.mas_equalTo(CGSizeMake(kWidth(610), kWidth(300)));
        }];
        
        [closeImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(headerView);
            make.right.equalTo(headerView.mas_right).offset(-kWidth(30));
            make.size.mas_equalTo(CGSizeMake(kWidth(46), kWidth(94)));
        }];
    }
}

- (void)configTableFooterView {
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = kColor(@"#ffffff");
    footerView.size = CGSizeMake(kWidth(610), kWidth(216));
    self.tableView.tableFooterView = footerView;
    
    UIButton *wxButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [wxButton setTitle:@"微信支付" forState:UIControlStateNormal];
    [wxButton setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
    wxButton.titleLabel.font = kFont(14);
    wxButton.layer.cornerRadius = 3;
    wxButton.backgroundColor = kColor(@"#00AC0A");
    [footerView addSubview:wxButton];
    
    UIButton *aliButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aliButton setTitle:@"支付宝" forState:UIControlStateNormal];
    [aliButton setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
    aliButton.titleLabel.font = kFont(14);
    aliButton.layer.cornerRadius = 3;
    aliButton.backgroundColor = kColor(@"#49ABF5");
    [footerView addSubview:aliButton];
    
    @weakify(self);
    [wxButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        [self payWithType:MSPayTypeWeiXin];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [aliButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        [self payWithType:MSPayTypeAliPay];
    } forControlEvents:UIControlEventTouchUpInside];

    {
        [wxButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.top.equalTo(footerView);
            make.size.mas_equalTo(CGSizeMake(kWidth(450), kWidth(76)));
        }];
        
        [aliButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(footerView);
            make.top.equalTo(wxButton.mas_bottom).offset(kWidth(20));
            make.size.mas_equalTo(CGSizeMake(kWidth(450), kWidth(76)));
        }];
    }
}

- (void)payWithType:(MSPayType)type {
    [[MSPaymentManager manager] startPayForVipLevel:[MSUtil currentVipLevel] + 1 type:type price:self.price handler:^(BOOL success) {
        [self hide];
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MSOpenVipSuccessNotification object:nil];
        }
    }];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSVipPayPointCell *cell = [tableView dequeueReusableCellWithIdentifier:kMSVipPayPointCellReusableIdentifier forIndexPath:indexPath];
    if (indexPath.row < 2) {
        cell.payPointLevel = indexPath.row;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kWidth(152);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MSVipPayPointCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.price = cell.price;
}

@end
