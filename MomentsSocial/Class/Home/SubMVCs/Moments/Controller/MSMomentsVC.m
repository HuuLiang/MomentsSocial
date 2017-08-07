//
//  MSMomentsVC.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/31.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMomentsVC.h"
#import "MSMomentsCell.h"
#import "MSCircleModel.h"
#import "MSMomentsModel.h"
#import "MSSendMomentsVC.h"
#import "MSNavigationController.h"
#import "MSReqManager.h"
#import "MSCommentsListVC.h"

static NSString *const kMSMomentsCellReusableIdentifier = @"kMSMomentsCellReusableIdentifier";

@interface MSMomentsVC () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *heights;
@property (nonatomic) NSMutableArray *dataSource;
@property (nonatomic) MSCircleInfo *circleInfo;
@end

@implementation MSMomentsVC
QBDefineLazyPropertyInitialization(NSMutableArray, heights)
QBDefineLazyPropertyInitialization(NSMutableArray, dataSource)

- (instancetype)initWithCircleInfo:(MSCircleInfo *)info {
    self = [super init];
    if (self) {
        _circleInfo = info;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.circleInfo.name;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    [_tableView registerClass:[MSMomentsCell class] forCellReuseIdentifier:kMSMomentsCellReusableIdentifier];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
    
    {
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_tableView QB_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self fetchMomentsListInfo];
    }];
    
    [_tableView QB_triggerPullToRefresh];

    
    [self configRightBarButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)fetchMomentsListInfo {
    @weakify(self);
    [[MSReqManager manager] fetchMomentsListInfoWithCircleId:self.circleInfo.circleId class:[MSMomentsModel class] completionHandler:^(BOOL success, MSMomentsModel * obj) {
        @strongify(self);
        [self.tableView QB_endPullToRefresh];
        if (success) {
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:obj.mood];
            [self calculateCellHeight];
        }
    }];
}

- (void)configRightBarButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"发帖" style:UIBarButtonItemStylePlain handler:^(id sender) {
        if ([MSUtil currentVipLevel] < MSLevelVip1) {
            [[MSPopupHelper helper] showPopupViewWithType:MSPopupTypePostMsg disCount:YES cancleAction:nil confirmAction:^{
                
            }];
        } else {
            MSSendMomentsVC *sendMomentsVC = [[MSSendMomentsVC alloc] initWithTitle:@"发帖"];
            MSNavigationController *sendMomentsNav = [[MSNavigationController alloc] initWithRootViewController:sendMomentsVC];
            if (!self.navigationController.isBeingPresented) {
                [self presentViewController:sendMomentsNav animated:YES completion:nil];
            }
        }
//        MSSendMomentsVC *sendMomentsVC = [[MSSendMomentsVC alloc] initWithTitle:@"发帖"];
//        MSNavigationController *sendMomentsNav = [[MSNavigationController alloc] initWithRootViewController:sendMomentsVC];
//        if (!self.navigationController.isBeingPresented) {
//            [self presentViewController:sendMomentsNav animated:YES completion:nil];
//        }
    }];
}


- (void)calculateCellHeight {
    [self.dataSource enumerateObjectsUsingBlock:^(MSMomentModel *  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat contentHeight = 0;;
        if (model.text.length > 0) {
            contentHeight = [model.text sizeWithFont:kFont(15) maxWidth:kWidth(630)].height + kWidth(20);
        }
        CGFloat photosHeight = 0;
        if (model.type == MSMomentsTypePhotos) {
            CGFloat photoheight = (kScreenWidth - kWidth(140))/3;
            NSInteger lineCount = ceilf(model.moodUrl.count / 3.0);
            photosHeight = lineCount * photoheight + ((lineCount > 0 ? lineCount : 1) - 1) * kWidth(10);
        } else if (model.type == MSMomentsTypeVideo) {
            photosHeight = (kScreenWidth - kWidth(120))/2;
        }
        CGFloat commentHeight = 0;
        __block MSMomentCommentsInfo *comment1 = nil;
        __block MSMomentCommentsInfo *comment2 = nil;
        [model.comments enumerateObjectsUsingBlock:^(MSMomentCommentsInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                comment1 = obj;
            } else if (idx == 1) {
                comment2 = obj;
            }
        }];
        commentHeight = kWidth(26) + [comment1.content sizeWithFont:kFont(13) maxWidth:kWidth(590)].height + kWidth(18) + [comment2.content sizeWithFont:kFont(13) maxWidth:kWidth(590)].height + kWidth(30);
        
        CGFloat height = kWidth(110) + contentHeight + photosHeight + kWidth(84) + commentHeight;
        [self.heights addObject:@(height)];
    }];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSMomentsCell *cell = [tableView dequeueReusableCellWithIdentifier:kMSMomentsCellReusableIdentifier forIndexPath:indexPath];
    if (indexPath.row < self.dataSource.count) {
        __block MSMomentModel *model = self.dataSource[indexPath.row];
        cell.userImgUrl = model.portraitUrl;
        cell.nickName = model.nickName;
        cell.location = @"蒋村街道办事处";
        cell.commentsCount = model.comments.count;
        cell.attentionCount = model.greet;
        cell.content = model.text;
        cell.momentsType = model.type;
        if (model.type == MSMomentsTypePhotos) {
            cell.dataSource = model.moodUrl;
        } else if (model.type == MSMomentsTypeVideo) {
            cell.dataSource = model.videoImg;
        }
        [model.comments enumerateObjectsUsingBlock:^(MSMomentCommentsInfo * _Nonnull comment, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                cell.nickA = comment.nickName;
                cell.commentA = comment.content;
            } else if (idx == 1) {
                cell.nickB = comment.nickName;
                cell.commentB = comment.content;
            }
        }];
        @weakify(cell);
        cell.greetAction = ^{
            @strongify(cell);
            if (model.greeted) {
                [[MSHudManager manager] showHudWithText:@"您已经点过赞"];
                return ;
            }
            
            [[MSReqManager manager] greetMomentWithMoodId:model.moodId Class:[QBDataResponse class] completionHandler:^(BOOL success, id obj) {
                if (success) {
                    [[MSHudManager manager] showHudWithText:@"点赞成功"];
                    cell.greeted = YES;
                    model.greeted = YES;
                    [model saveOrUpdate];
                }
            }];
            
        };
        
        @weakify(self);
        cell.commentAction = ^{
            @strongify(self);
            MSCommentsListVC *listVC = [[MSCommentsListVC alloc] initWithMomentId:model.moodId];
            [self.navigationController pushViewController:listVC animated:YES];
        };
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.heights.count) {
        return ceilf([self.heights[indexPath.row] floatValue]);
    }
    return 0;
}

@end
