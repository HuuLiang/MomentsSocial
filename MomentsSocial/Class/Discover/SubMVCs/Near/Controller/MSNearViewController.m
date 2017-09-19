//
//  MSNearViewController.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/27.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSNearViewController.h"
#import "MSNearCell.h"
#import "MSDetailViewController.h"
#import "MSReqManager.h"
#import "MSDisFuctionModel.h"
#import "QBLocationManager.h"
#import "MSMessageModel.h"

static NSString *const kMSNearCellReusableIdentifier = @"kMSNearCellReusableIdentifier";

@interface MSNearViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic) NSMutableArray <MSUserModel *> *dataSource;
@end

@implementation MSNearViewController
QBDefineLazyPropertyInitialization(NSMutableArray, dataSource)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = kColor(@"#f0f0f0");
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[MSNearCell class] forCellReuseIdentifier:kMSNearCellReusableIdentifier];
    _tableView.tableFooterView = [UIView new];
    [_tableView setSeparatorInset:UIEdgeInsetsMake(0, kWidth(30), 0, 0)];
    [self.view addSubview:_tableView];
    
    {
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_tableView QB_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self fetchNearInfo];
    }];
    
    [_tableView QB_triggerPullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)fetchNearInfo {
    @weakify(self);
    [[MSReqManager manager] fetchNearShakeInfoWithNumber:30 Class:[MSDisFuctionModel class] completionHandler:^(BOOL success, MSDisFuctionModel * obj) {
        @strongify(self);
        [self.tableView QB_endPullToRefresh];
        if (success) {
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:obj.users];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSNearCell *cell = [tableView dequeueReusableCellWithIdentifier:kMSNearCellReusableIdentifier forIndexPath:indexPath];
    if (indexPath.row < self.dataSource.count) {
        MSUserModel *user = self.dataSource[indexPath.item];
        
        cell.isGreeted = [MSUserModel isGreetedWithUserId:user.userId];
        cell.imgUrl = user.portraitUrl;
        cell.nickName = user.nickName;
        cell.age = user.age;
        
        @weakify(self,cell);
        
        [[QBLocationManager manager] getUserLacationNameWithUserId:[NSString stringWithFormat:@"%ld",(long)user.userId] locationName:^(BOOL success, NSString *locationName) {
            @strongify(cell);
            cell.location = locationName;
        }];
        
        cell.greetAction = ^{
            @strongify(cell,self);
            if (user.greeted) {
                [[MSHudManager manager] showHudWithText:@"已经打过招呼"];
            } else {
                if ([MSMessageModel addMessageInfoWithUserId:user.userId nickName:user.nickName portraitUrl:user.portraitUrl]) {
                    [[MSHudManager manager] showHudWithText:@"打招呼成功"];
                    user.greeted = YES;
                    cell.isGreeted = YES;
                    [user saveOrUpdate];
                    [self.dataSource replaceObjectAtIndex:indexPath.item withObject:user];
                }
            }
        };
        
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kWidth(180);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.dataSource.count) {
        MSUserModel *user = self.dataSource[indexPath.row];
        [self pushIntoDetailVCWithUserId:[NSString stringWithFormat:@"%ld",(long)user.userId]];
    }

}

@end
