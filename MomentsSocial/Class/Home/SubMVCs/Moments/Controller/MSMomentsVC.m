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
#import "MSOnlineManager.h"
#import "QBLocationManager.h"
#import "QBPhotoBrowser.h"
#import "QBVideoPlayer.h"
#import "MSMessageModel.h"

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOnline:) name:kMSPostOnlineInfoNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMSPostOnlineInfoNotification object:nil];
}

- (void)changeOnline:(NSNotification *)notification {
    MSOnlineInfo *onlineInfo = [notification object];
    dispatch_async(dispatch_queue_create(0, 0), ^{
       [self.dataSource enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(MSMomentModel *  _Nonnull momentModel, NSUInteger idx, BOOL * _Nonnull stop) {
           if (onlineInfo.userId == momentModel.userId) {
               MSMomentsCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
               dispatch_async(dispatch_get_main_queue(), ^{
                   cell.online = @(onlineInfo.online);
               });
           }
       }];
    });
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
            [[MSPopupHelper helper] showPopupViewWithType:MSPopupTypePostMoment disCount:NO cancleAction:nil confirmAction:^{
                [self pushVipViewController];
            }];
            return ;
        }
        MSSendMomentsVC *sendMomentsVC = [[MSSendMomentsVC alloc] initWithTitle:@"发帖"];
        MSNavigationController *sendMomentsNav = [[MSNavigationController alloc] initWithRootViewController:sendMomentsVC];
        if (!self.navigationController.isBeingPresented) {
            [self presentViewController:sendMomentsNav animated:YES completion:nil];
        }
    }];
}


- (void)calculateCellHeight {
    [self.dataSource enumerateObjectsUsingBlock:^(MSMomentModel *  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        __block CGFloat contentHeight = 0;
        
        contentHeight = contentHeight + kWidth(30) + kWidth(60);
        
        if (model.text.length > 0) {
            contentHeight = contentHeight + [model.text sizeWithFont:kFont(15) maxWidth:kWidth(630)].height + kWidth(20);
        }
        
        CGFloat photosHeight = 0;
        if (model.type == MSMomentsTypePhotos) {
            CGFloat photoheight = (kScreenWidth - kWidth(140))/3;
            NSInteger lineCount = ceilf(model.moodUrl.count / 3.0);
            photosHeight = lineCount * photoheight + ((lineCount > 0 ? lineCount : 1) - 1) * kWidth(10);
        } else if (model.type == MSMomentsTypeVideo) {
            photosHeight = (kScreenWidth - kWidth(120))/2;
        }
        contentHeight = contentHeight + photosHeight + kWidth(20) + kWidth(84);
        
        [model.comments enumerateObjectsUsingBlock:^(MSMomentCommentsInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                contentHeight = contentHeight + [[NSString stringWithFormat:@"%@：%@",obj.nickName,obj.content] sizeWithFont:kFont(13) maxWidth:kWidth(590)].height + kWidth(26) + kWidth(30);
            } else if (idx == 1) {
                contentHeight = contentHeight + [[NSString stringWithFormat:@"%@：%@",obj.nickName,obj.content] sizeWithFont:kFont(13) maxWidth:kWidth(590)].height + kWidth(24);
            }
        }];
        
        contentHeight = contentHeight + kWidth(20);
        
        [self.heights addObject:@(contentHeight)];
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
        cell.momentsType = model.type;
        cell.vipLv = self.circleInfo.vipLv;
        
        @weakify(cell);
        cell.greetAction = ^{
            @strongify(cell);
            if (model.greeted) {
                [[MSHudManager manager] showHudWithText:@"您已经打过招呼"];
                return ;
            }
            if ([MSMessageModel addMessageInfoWithUserId:model.userId nickName:model.nickName portraitUrl:model.portraitUrl]) {
                [[MSHudManager manager] showHudWithText:@"打招呼成功"];
                cell.greeted = @(1);
                model.greeted = YES;
                [model saveOrUpdate];
                [self.dataSource replaceObjectAtIndex:indexPath.row withObject:model];
            }
        };
        
        cell.loveAction = ^{
            @strongify(cell);
            if (model.loved) {
                [[MSHudManager manager] showHudWithText:@"您已经点过赞"];
                return ;
            }
            [[MSReqManager manager] greetMomentWithMoodId:model.moodId Class:[QBDataResponse class] completionHandler:^(BOOL success, id obj) {
                if (success) {
                    [[MSHudManager manager] showHudWithText:@"点赞成功"];
                    cell.loved = @(1);
                    model.loved = YES;
                    [model saveOrUpdate];
                    [self.dataSource replaceObjectAtIndex:indexPath.row withObject:model];
                }
            }];
        };
        
        @weakify(self);
        cell.commentAction = ^{
            @strongify(self);
            MSCommentsListVC *listVC = [[MSCommentsListVC alloc] initWithMomentId:model.moodId];
            [self.navigationController pushViewController:listVC animated:YES];
        };
        
        cell.photoAction = ^(id obj) {
            @strongify(self);
            BOOL needBlur = [MSUtil currentVipLevel] <= self.circleInfo.vipLv;
            
            [[QBPhotoBrowser browse] showPhotoBrowseWithImageUrl:model.moodUrl atIndex:[obj integerValue] needBlur:needBlur blurStartIndex:3 onSuperView:self.view handler:^{
                MSPopupType type;
                if (cell.vipLv == MSLevelVip0) {
                    type = MSPopupTypePhotoVip1;
                } else {
                    type = MSPopupTypePhotoVip2;
                }
                [[MSPopupHelper helper] showPopupViewWithType:type disCount:type == MSPopupTypePhotoVip2 cancleAction:nil confirmAction:^{
                    [self pushVipViewController];
                }];
            }];
        };
        
        cell.VideoAction = ^{
            @strongify(self);
            MSPopupType type;
            if ([MSUtil currentVipLevel] <= self.circleInfo.vipLv) {
                if (cell.vipLv == MSLevelVip0) {
                    type = MSPopupTypePhotoVip1;
                } else {
                    type = MSPopupTypePhotoVip2;
                }
                [[MSPopupHelper helper] showPopupViewWithType:type disCount:type == MSPopupTypePhotoVip2 cancleAction:nil confirmAction:^{
                    [self pushVipViewController];
                }];
            }
            //视频播放
            QBVideoPlayer * _videoPlayer = [[QBVideoPlayer alloc] initWithVideoURL:[NSURL URLWithString:model.videoUrl]];
            [self.view addSubview:_videoPlayer];
            {
                [_videoPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.view);
                }];
            }
            [_videoPlayer startToPlay];
            
            @weakify(_videoPlayer);
            _videoPlayer.endPlayAction = ^(id obj) {
                @strongify(_videoPlayer);
                [_videoPlayer pause];
                [_videoPlayer removeFromSuperview];
                _videoPlayer = nil;
            };
        };
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    MSMomentsCell *momentsCell = (MSMomentsCell *)cell;
    if (indexPath.row < self.dataSource.count) {
        __block MSMomentModel *model = self.dataSource[indexPath.row];
        if (!momentsCell.userImgUrl)            {momentsCell.userImgUrl = model.portraitUrl;}
        if (!momentsCell.nickName)              {momentsCell.nickName = model.nickName;}
        if (!momentsCell.online)                {momentsCell.online = @([[MSOnlineManager manager] onlineWithUserId:model.userId]);}
        if (!momentsCell.greeted)               {momentsCell.greeted = @([model isGreeted]);}
        if (!momentsCell.content)               {momentsCell.content = model.text;}
        
        if (model.type == MSMomentsTypePhotos) {
            momentsCell.dataSource = model.moodUrl;
        } else if (model.type == MSMomentsTypeVideo) {
            momentsCell.dataSource = model.videoImg;
        }
        
        if (!momentsCell.commentsCount)         {momentsCell.commentsCount = @(model.commentCount);}
        if (!momentsCell.attentionCount)        {momentsCell.attentionCount = @(model.likesNumber);}
        if (!momentsCell.loved)                 {momentsCell.loved = @([model loved]);}
        
        if (!momentsCell.location) {
            [[QBLocationManager manager] getUserLacationNameWithUserId:[NSString stringWithFormat:@"%ld",model.userId] locationName:^(BOOL success, NSString *locationName) {
                momentsCell.location = locationName;
            }];
        }
        
        [model.comments enumerateObjectsUsingBlock:^(MSMomentCommentsInfo * _Nonnull comment, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                momentsCell.nickA = comment.nickName;
                momentsCell.commentA = comment.content;
            } else if (idx == 1) {
                momentsCell.nickB = comment.nickName;
                momentsCell.commentB = comment.content;
            }
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.heights.count) {
        return ceilf([self.heights[indexPath.row] floatValue]);
    }
    return 0;
}

@end
