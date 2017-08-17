//
//  MSDetailPhotosVC.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/1.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSDetailPhotosVC.h"
#import "MSDetailPhotoCell.h"
#import "QBPhotoBrowser.h"

static NSString *const kMSDetailPhotoCellReusableIdentifier = @"kMSDetailPhotoCellReusableIdentifier";

@interface MSDetailPhotosVC () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) NSArray *photos;
@end

@implementation MSDetailPhotosVC

- (instancetype)initWithPhotos:(NSArray *)photos {
    self = [super init];
    if (self) {
        _photos = photos;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"相册";
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = kWidth(20);
    layout.minimumInteritemSpacing = kWidth(10);
    layout.sectionInset = UIEdgeInsetsMake(kWidth(20), kWidth(20), kWidth(20), kWidth(20));
    CGFloat itemWidth = (kScreenWidth - kWidth(60))/3;
    layout.itemSize = CGSizeMake(floorf(itemWidth), floorf(itemWidth));
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = kColor(@"#ffffff");
    [_collectionView registerClass:[MSDetailPhotoCell class] forCellWithReuseIdentifier:kMSDetailPhotoCellReusableIdentifier];
    [self.view addSubview:_collectionView];
    
    {
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MSDetailPhotoCell *cell= [collectionView dequeueReusableCellWithReuseIdentifier:kMSDetailPhotoCellReusableIdentifier forIndexPath:indexPath];
    if (indexPath.item < self.photos.count) {
        cell.imgUrl = self.photos[indexPath.item];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[QBPhotoBrowser browse] showPhotoBrowseWithImageUrl:self.photos atIndex:indexPath.item needBlur:NO blurStartIndex:0 onSuperView:self.view handler:nil];
}

@end
