//
//  MSVipViewController.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSVipViewController.h"
#import "MSPayTypeCell.h"

static NSString *const kMSPayInfoCellReusableIdentifier = @"kMSPayInfoCellReusableIdentifier";
static NSString *const kMSPayTypeCellReusableIdentifier = @"kMSPayTypeCellReusableIdentifier";
static NSString *const kMSPayDescCellReusableIdentifier = @"kMSPayDescCellReusableIdentifier";

@interface MSVipViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@end

@implementation MSVipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"支付订单";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    [_tableView registerClass:[MSPayTypeCell class] forCellReuseIdentifier:kMSPayTypeCellReusableIdentifier];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kMSPayInfoCellReusableIdentifier];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kMSPayDescCellReusableIdentifier];
    [self.view addSubview:_tableView];
    
    {
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 2;
    } else if (section == 2) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
    } else if (indexPath.section == 1) {
        
    } else if (indexPath.section == 2) {
        
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

@end
