//
//  MSCommentsListVC.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/7.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSCommentsListVC.h"
#import "MSCommentCell.h"
#import "MSCommentsModel.h"
#import "MSMomentsModel.h"
#import "MSReqManager.h"

static NSString *const kMSMomentCommentsListCellReusableIdentifier = @"kMSMomentCommentsListCellReusableIdentifier";

@interface MSCommentsListVC () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSInteger momentId;
@property (nonatomic) NSMutableArray *dataSource;
@property (nonatomic) NSMutableArray *heights;
@end

@implementation MSCommentsListVC
QBDefineLazyPropertyInitialization(NSMutableArray, dataSource)
QBDefineLazyPropertyInitialization(NSMutableArray, heights)

- (instancetype)initWithMomentId:(NSInteger)momentId {
    self = [super init];
    if (self) {
        _momentId = momentId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    [_tableView setSeparatorColor:kColor(@"#f0f0f0")];
    [_tableView setSeparatorInset:UIEdgeInsetsMake(-0.5, kWidth(30), -0.5, kWidth(30))];
    [_tableView registerClass:[MSCommentCell class] forCellReuseIdentifier:kMSMomentCommentsListCellReusableIdentifier];
    [self.view addSubview:_tableView];
    {
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    @weakify(self);
    [_tableView QB_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self fetchCommentsInfo];
    }];
    [_tableView QB_triggerPullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)fetchCommentsInfo {
    @weakify(self);
    [[MSReqManager manager] fetchCommentsWithMomentId:self.momentId Class:[MSCommentsModel class] completionHandler:^(BOOL success, MSCommentsModel * obj) {
        @strongify(self);
        [self.tableView QB_endPullToRefresh];
        if (success) {
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:obj.comments];
            [self calculateCellHeight];
        }
    }];
}

- (void)calculateCellHeight {
    [self.dataSource enumerateObjectsUsingBlock:^(MSMomentCommentsInfo *  _Nonnull comment, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat height = 0;;
        CGFloat contentHeight = [comment.content sizeWithFont:kFont(15) maxWidth:kWidth(690)].height;
        
        height = kWidth(110) + contentHeight;
        [self.heights addObject:@(height)];
    }];
    [self.tableView reloadData];
}


#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kMSMomentCommentsListCellReusableIdentifier forIndexPath:indexPath];
    if (indexPath.row < self.dataSource.count) {
        MSMomentCommentsInfo *comment = self.dataSource[indexPath.row];
        cell.nickName = comment.nickName;
        cell.content = comment.content;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ceilf([self.heights[indexPath.row] floatValue]);
}

@end
