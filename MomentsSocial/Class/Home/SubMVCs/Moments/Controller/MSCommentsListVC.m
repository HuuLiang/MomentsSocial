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
#import "MSVipVC.h"

static NSString *const kMSMomentCommentsListCellReusableIdentifier = @"kMSMomentCommentsListCellReusableIdentifier";

@interface MSCommentsListVC () <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
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
    
    [self configRightBarButton];
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

- (void)configRightBarButton {
    @weakify(self)
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"评论" style:UIBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        if ([MSUtil currentVipLevel] == MSLevelVip0) {
            [[MSPopupHelper helper] showPopupViewWithType:MSPopupTypeSendComment disCount:NO cancleAction:nil confirmAction:^{
                @strongify(self);
                [MSVipVC showVipViewControllerInCurrentVC:self contentType:MSPopupTypeSendComment];
            }];
            return ;
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"评论" message:@"期待您的神评" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发表", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];

    }];
}
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
    } else if (buttonIndex == 1) {
        [[MSHudManager manager] showHudWithText:@"发表成功，审核中"];
    }
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
