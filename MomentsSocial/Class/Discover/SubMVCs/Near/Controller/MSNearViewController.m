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

@interface MSNearViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) NSMutableArray <MSUserModel *> *dataSource;
@end

@implementation MSNearViewController
QBDefineLazyPropertyInitialization(NSMutableArray, dataSource)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(kWidth(20), kWidth(20), kWidth(20), kWidth(20));
    layout.minimumLineSpacing = kWidth(20);
    layout.minimumInteritemSpacing = kWidth(20);
    CGFloat itemWidth = floor(kScreenWidth - kWidth(60))/2;
    CGFloat itemHeight = itemWidth + kWidth(88);
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [_collectionView registerClass:[MSNearCell class] forCellWithReuseIdentifier:kMSNearCellReusableIdentifier];
    _collectionView.backgroundColor = kColor(@"#f0f0f0");
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    
    {
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_collectionView QB_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self fetchNearInfo];
    }];
    
    [_collectionView QB_triggerPullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)fetchNearInfo {
    @weakify(self);
    [[MSReqManager manager] fetchNearShakeInfoWithNumber:30 Class:[MSDisFuctionModel class] completionHandler:^(BOOL success, MSDisFuctionModel * obj) {
        @strongify(self);
        [self.collectionView QB_endPullToRefresh];
        if (success) {
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:obj.users];
            [self.collectionView reloadData];
        }
    }];
}

#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MSNearCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMSNearCellReusableIdentifier forIndexPath:indexPath];
    if (indexPath.item < self.dataSource.count) {
        MSUserModel *user = self.dataSource[indexPath.item];
        
        @weakify(cell);
        @weakify(self);
        cell.greetAction = ^{
            @strongify(self);
            @strongify(cell);
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

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    MSNearCell *nearCell = (MSNearCell *)cell;
    if (indexPath.item < self.dataSource.count) {
        MSUserModel *user = self.dataSource[indexPath.item];
        nearCell.isGreeted = [user greeted];
        if (!nearCell.imgUrl) {
            nearCell.imgUrl = user.portraitUrl;
        }
        if (!nearCell.nickName) {
            nearCell.nickName = user.nickName;
        }
        if (!nearCell.age) {
            nearCell.age = user.age;
        }
        if (!nearCell.sex) {
            nearCell.sex = user.sex;
        }

        if (!nearCell.location) {
            @weakify(nearCell);
            [[QBLocationManager manager] getUserLacationNameWithUserId:[NSString stringWithFormat:@"%ld",(long)user.userId] locationName:^(BOOL success, NSString *locationName) {
                @strongify(nearCell);
                nearCell.location = locationName;
            }];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < self.dataSource.count) {
        MSUserModel *user = self.dataSource[indexPath.item];
        [self pushIntoDetailVCWithUserId:[NSString stringWithFormat:@"%ld",(long)user.userId]];
    }
}

@end
