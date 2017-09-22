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
#import "MSVipVC.h"
#import "MSDetailViewController.h"

static NSString *const kMSMomentsCellReusableIdentifier = @"kMSMomentsCellReusableIdentifier";

@interface MSMomentsVC () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *heights;
@property (nonatomic) NSMutableArray *dataSource;
@property (nonatomic) MSCircleInfo *circleInfo;
@property (nonatomic) QBVideoPlayer *videoPlayer;
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
    _tableView.tableFooterView = [UIView new];
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
    
    
    [_tableView QB_addPagingRefreshWithMomentsVip:self.circleInfo.vipLv Handler:^{
        @strongify(self);
        if ([MSUtil currentVipLevel] == MSLevelVip0) {
            [[MSPopupHelper helper] showPopupViewWithType:MSPopupTypeMoreMoments disCount:NO cancleAction:nil confirmAction:^{
                @strongify(self);
                [MSVipVC showVipViewControllerInCurrentVC:self contentType:MSPopupTypeMoreMoments];
            }];
        }
        [self.tableView QB_endPullToRefresh];
    }];
    
    [self configRightBarButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOnline:) name:kMSPostOnlineInfoNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)dealloc {
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMSPostOnlineInfoNotification object:nil];
}

- (void)changeOnline:(NSNotification *)notification {
    MSOnlineInfo *onlineInfo = [notification object];
    dispatch_async(dispatch_queue_create(0, 0), ^{
       [self.dataSource enumerateObjectsUsingBlock:^(MSMomentModel *  _Nonnull momentModel, NSUInteger idx, BOOL * _Nonnull stop) {
           if (onlineInfo.userId == momentModel.userId) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
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
    @weakify(self)
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"发帖" style:UIBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        if ([MSUtil currentVipLevel] < MSLevelVip1) {
            [[MSPopupHelper helper] showPopupViewWithType:MSPopupTypePostMoment disCount:NO cancleAction:nil confirmAction:^{
                @strongify(self);
                [MSVipVC showVipViewControllerInCurrentVC:self contentType:MSPopupTypePostMoment];
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
    [self.heights removeAllObjects];
    [self.dataSource enumerateObjectsUsingBlock:^(MSMomentModel *  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [[MSOnlineManager manager] addUser:model.userId type:MSUserTypeCircle handler:^(BOOL online) {
            
        }];
        
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

- (void)showVideoPlayerViewWithVideoUrl:(NSString *)videoUrl {
    //视频播放
    self.videoPlayer = [[QBVideoPlayer alloc] initWithVideoURL:[NSURL URLWithString:videoUrl]];
    [self.view addSubview:_videoPlayer];
    {
        [_videoPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    [_videoPlayer startToPlay];
    
    @weakify(self);
    _videoPlayer.endPlayAction = ^(id obj) {
        @strongify(self);
        [self.videoPlayer pause];
        [self.videoPlayer removeFromSuperview];
        self.videoPlayer = nil;
    };
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
        
        @weakify(self,model,cell);
        cell.detailAction = ^{
            @strongify(self,model);
            MSDetailViewController *detailVC = [[MSDetailViewController alloc] initWithUserId:[NSString stringWithFormat:@"%ld",(long)model.userId]];
            [self.navigationController pushViewController:detailVC animated:YES];
        };
        
        cell.greetAction = ^{
            @strongify(self,cell,model);
            if ([cell.greeted boolValue]) {
                [[MSHudManager manager] showHudWithText:@"您已经打过招呼"];
                return ;
            }
            if ([MSMessageModel addMessageInfoWithUserId:model.userId nickName:model.nickName portraitUrl:model.portraitUrl]) {
                [[MSHudManager manager] showHudWithText:@"打招呼成功"];
                cell.greeted = @(1);
                model.greeted = YES;
                [model setUserGreeted:YES];
                [model saveOrUpdate];
                [self.dataSource replaceObjectAtIndex:indexPath.row withObject:model];
            }
        };
        
        cell.loveAction = ^{
            @strongify(self,cell,model);
            if (cell.loved.boolValue) {
                [[MSHudManager manager] showHudWithText:@"您已经点过赞"];
                return ;
            }
            [[MSReqManager manager] greetMomentWithMoodId:model.moodId Class:[QBDataResponse class] completionHandler:^(BOOL success, id obj) {
                @strongify(self,cell,model);
                if (success) {
                    [[MSHudManager manager] showHudWithText:@"点赞成功"];
                    cell.loved = @(1);
                    model.likesNumber++;
                    cell.attentionCount = @(model.likesNumber);
                    model.loved = YES;
                    [model saveOrUpdate];
                    [self.dataSource replaceObjectAtIndex:indexPath.row withObject:model];
                }
            }];
        };
        
        cell.commentAction = ^{
            @strongify(self,model);
            MSCommentsListVC *listVC = [[MSCommentsListVC alloc] initWithMomentId:model.moodId];
            [self.navigationController pushViewController:listVC animated:YES];
        };
        
        cell.photoAction = ^(NSNumber * indexNum) {
            @strongify(self,model,cell);
            NSNumber * type;
            if (cell.vipLv == MSLevelVip0) {
                type = @(MSPopupTypePhotoVip1);
            } else {
                type = @(MSPopupTypePhotoVip2);
            }
            @weakify(type);
            BOOL needBlur = [MSUtil currentVipLevel] <= self.circleInfo.vipLv;
            [[QBPhotoBrowser browse] showPhotoBrowseWithImageUrl:model.moodUrl atIndex:[indexNum integerValue] needBlur:needBlur blurStartIndex:3 onSuperView:self.view handler:^{
                @strongify(self,type);
                [[MSPopupHelper helper] showPopupViewWithType:[type integerValue] disCount:[type integerValue] == MSPopupTypePhotoVip2 cancleAction:nil confirmAction:^{
                    @strongify(self);
                    [[QBPhotoBrowser browse] closeBrowse];
                    [MSVipVC showVipViewControllerInCurrentVC:self contentType:[type integerValue]];
                }];
            }];
        };
        
        cell.VideoAction = ^{
            @strongify(self,model,cell);
            MSPopupType  type;
            if ([MSUtil currentVipLevel] <= self.circleInfo.vipLv) {
                if (cell.vipLv == MSLevelVip0) {
                    type = MSPopupTypePhotoVip1;
                } else {
                    type = MSPopupTypePhotoVip2;
                }
                [[MSPopupHelper helper] showPopupViewWithType:type disCount:type == MSPopupTypePhotoVip2 cancleAction:nil confirmAction:^{
                    @strongify(self);
                    [MSVipVC showVipViewControllerInCurrentVC:self contentType:type];
                }];
                return ;
            }
            [self showVideoPlayerViewWithVideoUrl:model.videoUrl];
        };
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    MSMomentsCell *momentsCell = (MSMomentsCell *)cell;
    if (indexPath.row < self.dataSource.count) {
        __block MSMomentModel *model = self.dataSource[indexPath.row];
        momentsCell.vipLv = self.circleInfo.vipLv;
//        if (![momentsCell.userImgUrl isEqualToString:model.portraitUrl])            {
            momentsCell.userImgUrl = model.portraitUrl;
//        }
//        if (![momentsCell.nickName isEqualToString:model.nickName])              {
            momentsCell.nickName = model.nickName;
//        }
//        if (!momentsCell.online) {
            momentsCell.online = [NSNumber numberWithBool:[[MSOnlineManager manager] onlineWithUserId:model.userId]];
//        }
//        if (!momentsCell.greeted)               {
            momentsCell.greeted = @([model isGreeted]);
//        }
//        if (![momentsCell.content isEqualToString:model.text])               {
            momentsCell.content = model.text;
//        }
        
        if (model.type == MSMomentsTypePhotos) {
            momentsCell.dataSource = model.moodUrl;
        } else if (model.type == MSMomentsTypeVideo) {
            momentsCell.dataSource = model.videoImg;
        }
        
//        if (!momentsCell.commentsCount)         {
            momentsCell.commentsCount = @(model.commentCount);
//        }
//        if (!momentsCell.attentionCount)        {
            momentsCell.attentionCount = @(model.likesNumber);
//        }
//        if (!momentsCell.loved)                 {
            momentsCell.loved = @([model isLoved]);
//        }
        
        if (!momentsCell.location) {
            @weakify(momentsCell);
            [[QBLocationManager manager] getUserLacationNameWithUserId:[NSString stringWithFormat:@"%ld",model.userId] locationName:^(BOOL success, NSString *locationName) {
                @strongify(momentsCell);
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
