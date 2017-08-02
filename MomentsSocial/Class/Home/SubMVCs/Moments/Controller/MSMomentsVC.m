//
//  MSMomentsVC.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/31.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMomentsVC.h"
#import "MSMomentsCell.h"
#import "MSMomentsModel.h"
#import "MSSendMomentsVC.h"
#import "MSNavigationController.h"

static NSString *const kMSMomentsCellReusableIdentifier = @"kMSMomentsCellReusableIdentifier";

@interface MSMomentsVC () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *heights;
@property (nonatomic) NSMutableArray *dataSource;
@end

@implementation MSMomentsVC
QBDefineLazyPropertyInitialization(NSMutableArray, heights)
QBDefineLazyPropertyInitialization(NSMutableArray, dataSource)

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    [self addData];
    [self configRightBarButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)configRightBarButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"发帖" style:UIBarButtonItemStylePlain handler:^(id sender) {
        if ([MSUtil currentVipLevel] < MSLevelVip1) {
            [[MSPopupHelper helper] showPopupViewWithType:MSPopupTypePostMsg disCount:NO cancleAction:nil confirmAction:^{
                
            }];
        } else {
            MSSendMomentsVC *sendMomentsVC = [[MSSendMomentsVC alloc] initWithTitle:@"发帖"];
            MSNavigationController *sendMomentsNav = [[MSNavigationController alloc] initWithRootViewController:sendMomentsVC];
            if (!self.navigationController.isBeingPresented) {
                [self presentViewController:sendMomentsNav animated:YES completion:nil];
            }
        }
    }];
}

- (void)addData {
    for (NSInteger i = 0; i < 10; i++) {
        MSMomentModel *model = [[MSMomentModel alloc] init];
        model.content = [NSString stringWithFormat:@"%ld自己觉得5分的颜值，8分的身材，0分的智商，2分的情商。你们觉得呢？",i];
        model.nick1 = @"段子界的清流:";
        model.nick2 = @"段子界的清流:";
        model.comment1 = @"段子界的清流:妹妹哪里的啊！哥哥我今晚有空，";
        model.comment2 = @"段子界的清流:妹妹哪里的啊！哥哥我今晚有空，是否赏脸约出来吃个";
        model.momentsType = i%2;
        model.photosCount = i;
        NSMutableArray *array = [NSMutableArray array];
        for (NSInteger j = 0; j < i; j++) {
            NSString *ss = @"";
            [array addObject:ss];
        }
        model.dataSource = array;
        
        [self.dataSource addObject:model];
    }
    [self calculateCellHeight];
}

- (void)calculateCellHeight {
    [self.dataSource enumerateObjectsUsingBlock:^(MSMomentModel *  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat contentHeight = 0;;
        if (model.content.length > 0) {
            contentHeight = [model.content sizeWithFont:kFont(15) maxWidth:kWidth(630)].height + kWidth(20);
        }
        CGFloat photosHeight = 0;
        if (model.momentsType == MSMomentsTypePhotos) {
            CGFloat photoheight = (kScreenWidth - kWidth(140))/3;
            NSInteger lineCount = ceilf(model.photosCount / 3.0);
            photosHeight = lineCount * photoheight + ((lineCount > 0 ? lineCount : 1) - 1) * kWidth(10);
        } else if (model.momentsType == MSMomentsTypeVideo) {
            photosHeight = (kScreenWidth - kWidth(120))/2;
        }
        CGFloat commentHeight = 0;
        commentHeight = kWidth(26) + [model.comment1 sizeWithFont:kFont(13) maxWidth:kWidth(590)].height + kWidth(18) + [model.comment2 sizeWithFont:kFont(13) maxWidth:kWidth(590)].height + kWidth(30);
        
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
        MSMomentModel *model = self.dataSource[indexPath.row];
        cell.userImgUrl = @"";
        cell.nickName = @"匿名传说";
        cell.location = @"蒋村街道办事处";
        cell.commentsCount = 460;
        cell.attentionCount = 24567;
        cell.content = model.content;
        cell.momentsType = model.momentsType;
        cell.dataSource = model.dataSource;
        cell.nickA = model.nick1;
        cell.nickB = model.nick2;
        cell.commentA = model.comment1;
        cell.commentB = model.comment2;
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
