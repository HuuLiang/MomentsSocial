//
//  MSHomeViewController.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSHomeViewController.h"
#import "MSHomeModel.h"
#import "MSReqManager.h"
#import "MSHomeMomentsCell.h"
#import "MSHomeCategoryCell.h"
#import "MSHomeCollectionHeaderView.h"
#import "MSComentsListVC.h"
#import "MSMomentsVC.h"

static NSString *const kMSHomeMomentsCellReusableIdentifier             = @"kMSHomeMomentsCellReusableIdentifier";
static NSString *const kMSHomeCategoryCellReusableIdentifier            = @"kMSHomeCategoryCellReusableIdentifier";
static NSString *const kMSHomeCollectionHeaderViewReusableIdentifier    = @"kMSHomeCollectionHeaderViewReusableIdentifier";
static NSString *const kMSHomeCollectionFooterViewReusableIdentifier    = @"kMSHomeCollectionFooterViewReusableIdentifier";

@interface MSHomeViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) MSHomeModel *response;
@end

@implementation MSHomeViewController
QBDefineLazyPropertyInitialization(MSHomeModel, response)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = kColor(@"#f0f0f0");
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[MSHomeMomentsCell class] forCellWithReuseIdentifier:kMSHomeMomentsCellReusableIdentifier];
    [_collectionView registerClass:[MSHomeCategoryCell class] forCellWithReuseIdentifier:kMSHomeCategoryCellReusableIdentifier];
    [_collectionView registerClass:[MSHomeCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMSHomeCollectionHeaderViewReusableIdentifier];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kMSHomeCollectionFooterViewReusableIdentifier];
    [self.view addSubview:_collectionView];
    
    {
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_collectionView QB_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self fetchHomeData];
    }];
    
    [_collectionView QB_triggerPullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)fetchHomeData {
    @weakify(self)
    [[MSReqManager manager] fetchHomeInfoWithCompletionHandler:^(BOOL success, MSHomeModel * obj) {
        @strongify(self);
        [self.collectionView QB_endPullToRefresh];
        if (success) {
            self.response = obj;
            [self.collectionView reloadData];
        }
    }];
}

#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    } else if (section == 1) {
        return 6;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MSHomeMomentsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMSHomeMomentsCellReusableIdentifier forIndexPath:indexPath];
        if (indexPath.item < 10) {
            cell.imgUrl = @"";
            cell.title = @"你爆照 我打分";
            cell.subTitle = @"默默的美美的发了一张照片【照片】";
            cell.count = 11111;
            cell.vipLevel = 0;
        }
        return cell;
    } else if (indexPath.section == 1) {
        MSHomeCategoryCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMSHomeCategoryCellReusableIdentifier forIndexPath:indexPath];
        if (indexPath.item < 10) {
            cell.imgUrl = @"";
            cell.title = @"你爆照 我打分";
            cell.subTitle = @"默默的美美的发了一张照片【照片】";
            cell.vipLevel = 0;
            @weakify(self);
            cell.joinAction = ^{
                @strongify(self);
                MSComentsListVC *listVC = [[MSComentsListVC alloc] initWithTitle:@"爆照"];
                [self.navigationController pushViewController:listVC animated:YES];
            };
        }
        return cell;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.item < 10) {
            MSMomentsVC *momentsVC = [[MSMomentsVC alloc] initWithTitle:@"你爆照 我打分"];
            [self.navigationController pushViewController:momentsVC animated:YES];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    const CGFloat fullWidth = CGRectGetWidth(collectionView.frame);
    const UIEdgeInsets sectionInsets = [self collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:indexPath.section];
    const CGFloat itemSpacing = [self collectionView:collectionView layout:collectionViewLayout minimumInteritemSpacingForSectionAtIndex:indexPath.section];
    if (indexPath.section == 0) {
        CGFloat width = fullWidth - sectionInsets.left - sectionInsets.right;
        return CGSizeMake(width, kWidth(144));
    } else if (indexPath.section == 1) {
        CGFloat width = (fullWidth - sectionInsets.left - sectionInsets.right - itemSpacing)/2;
        return CGSizeMake(width, width);
    }
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        MSHomeCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kMSHomeCollectionHeaderViewReusableIdentifier forIndexPath:indexPath];
        if (indexPath.section == 0) {
            headerView.title = @"热门圈";
        } else if (indexPath.section == 1) {
            headerView.title = @"全部圈子";
        }
        return headerView;
    } else if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kMSHomeCollectionFooterViewReusableIdentifier forIndexPath:indexPath];
        footerView.backgroundColor = kColor(@"#f0f0f0");
        return footerView;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(kScreenWidth, kWidth(90));
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(kScreenWidth, kWidth(20));
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return UIEdgeInsetsMake(1, 0, 1, 0);
    } else if (section == 1) {
        return UIEdgeInsetsMake(1, 0, 1, 0);
    }
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else if (section == 1) {
        return 1.5;
    }
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return 1.5;
    } else if (section == 1) {
        return 1.5;
    }
    return 0;
}

@end
