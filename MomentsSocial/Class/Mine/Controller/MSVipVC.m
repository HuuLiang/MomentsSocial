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
#import <UMMobClick/MobClick.h>
#import "MSSystemConfigModel.h"

static NSString *const kMSVipPayPointCellReusableIdentifier = @"kMSVipPayPointCellReusableIdentifier";

@interface MSVipVC () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSInteger price;
@property (nonatomic) MSPopupType contentType;
@property (nonatomic) NSArray <MSPayInfo *> * payPoints;
@end

@implementation MSVipVC

+ (void)showVipViewControllerInCurrentVC:(UIViewController *)currentViewController contentType:(MSPopupType)contentType {
    [MSVipVC showVipViewControllerInCurrentVC:currentViewController contentType:contentType payPoints:nil];
}

+ (void)showVipViewControllerInCurrentVC:(UIViewController *)currentViewController contentType:(MSPopupType)contentType payPoints:(NSArray<MSPayInfo *> *)payPoints {
    MSVipVC *vipVC = [[MSVipVC alloc] init];
    vipVC.contentType = contentType;
    if (payPoints) {
        vipVC.payPoints = payPoints;
    }
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
            make.size.mas_equalTo(CGSizeMake(kWidth(610), kWidth(900)));
        }];
    }
    
    [self configTableHeaderView];
    [self configTableFooterView];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
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
    
    CGFloat footerHeight = 0;
    
    if ([[MSPaymentManager manager] weixinPayEnable]) {
        UIButton *wxButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [wxButton setTitle:@"微信支付" forState:UIControlStateNormal];
        [wxButton setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
        wxButton.titleLabel.font = kFont(14);
        wxButton.layer.cornerRadius = 3;
        wxButton.backgroundColor = kColor(@"#00AC0A");
        [footerView addSubview:wxButton];
        
        @weakify(self);
        [wxButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            [self payWithType:MSPayTypeWeiXin];
        } forControlEvents:UIControlEventTouchUpInside];

        [wxButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.top.equalTo(footerView);
            make.size.mas_equalTo(CGSizeMake(kWidth(450), kWidth(76)));
        }];

        footerHeight += kWidth(120);
    }
    
    if ([[MSPaymentManager manager] aliPayEnable]) {
        UIButton *aliButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [aliButton setTitle:@"支付宝" forState:UIControlStateNormal];
        [aliButton setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
        aliButton.titleLabel.font = kFont(14);
        aliButton.layer.cornerRadius = 3;
        aliButton.backgroundColor = kColor(@"#49ABF5");
        [footerView addSubview:aliButton];
        
        @weakify(self);
        [aliButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            [self payWithType:MSPayTypeAliPay];
        } forControlEvents:UIControlEventTouchUpInside];
        
        {
            
            [aliButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(footerView);
                make.bottom.equalTo(footerView.mas_bottom).offset(-kWidth(40));
                make.size.mas_equalTo(CGSizeMake(kWidth(450), kWidth(76)));
            }];
        }
        
        footerHeight += kWidth(120);
    }
    footerView.size = CGSizeMake(kWidth(610), footerHeight);
}

- (void)payWithType:(MSPayType)type {
    @weakify(self);
    [MobClick event:MS_UMENG_STARTPAY_EVENT attributes:@{@"contentType":@(self.contentType)}];
    MSLevel targetLevel = MSLevelVip0;
    if (!self.payPoints) {
        targetLevel = [MSUtil currentVipLevel] + 1;
    } else {
        if ([MSUtil currentVipLevel] == MSLevelVip0) {
            targetLevel = [MSUtil currentVipLevel] + 1;
        } else {
            targetLevel = MSLevelVip1;
        }
    }
    [[MSPaymentManager manager] startPayForVipLevel:targetLevel type:type price:self.price contentType:self.contentType payPoints:self.payPoints handler:^(BOOL success) {
        @strongify(self);
        [self hide];
        if (success) {
            [MobClick event:MS_UMENG_RESULTPAY_EVENT attributes:@{@"contentType":@(self.contentType),
                                                                  @"Result":@(success)}];
            [MobClick event:MS_UMENG_MONEY_EVENT attributes:@{@"price":@(self.price)}];
            [[NSNotificationCenter defaultCenter] postNotificationName:MSOpenVipSuccessNotification object:nil];
        }
    }];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.payPoints ? self.payPoints.count : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSVipPayPointCell *cell = [tableView dequeueReusableCellWithIdentifier:kMSVipPayPointCellReusableIdentifier forIndexPath:indexPath];
    if (indexPath.row < [self tableView:self.tableView numberOfRowsInSection:0]) {
        if (self.payPoints.count > indexPath.row) {
            cell.payPoint = self.payPoints[indexPath.row];
        }
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
