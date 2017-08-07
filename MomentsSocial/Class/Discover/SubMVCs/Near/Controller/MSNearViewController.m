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

static NSString *const kMSNearCellReusableIdentifier = @"kMSNearCellReusableIdentifier";

@interface MSNearViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) NSMutableArray *dataSource;
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
        cell.imgUrl = user.portraitUrl;
        cell.nickName = user.nickName;
        cell.age = user.age;
        cell.sex = user.sex;
        cell.location = @"蒋村街道办事处";
        cell.isGreeted = NO;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < self.dataSource.count) {
        MSUserModel *user = self.dataSource[indexPath.item];
        [self pushIntoDetailVCWithUserId:user.userId];
    }
}

@end
