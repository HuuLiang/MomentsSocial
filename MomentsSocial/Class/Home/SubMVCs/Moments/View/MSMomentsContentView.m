//
//  MSMomentsContentView.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/31.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMomentsContentView.h"

static NSString *const kMSMomentsCellReusableIdentifier = @"kMSMomentsCellReusableIdentifier";

@interface MSMomentsContentView () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic) NSMutableArray *mutableArr;
@end

@implementation MSMomentsContentView
QBDefineLazyPropertyInitialization(NSMutableArray, mutableArr)

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewFlowLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        
        self.delegate = (id<UICollectionViewDelegate>)self;
        self.dataSource = (id<UICollectionViewDataSource>)self;
        
        self.backgroundColor = [UIColor blueColor];
        layout.minimumLineSpacing = kWidth(10);
        layout.minimumInteritemSpacing = kWidth(10);
        self.collectionViewLayout = layout;
        [self registerClass:[MSMomentsContentCell class] forCellWithReuseIdentifier:kMSMomentsCellReusableIdentifier];
        
    }
    return self;
}

- (void)setDataArr:(NSArray *)dataArr {
    [self.mutableArr removeAllObjects];
    [self.mutableArr addObjectsFromArray:dataArr];
    [self reloadData];
}

#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.mutableArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MSMomentsContentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMSMomentsCellReusableIdentifier forIndexPath:indexPath];
    if (indexPath.item < self.mutableArr.count) {
        cell.imgUrl = @"";
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = (kScreenWidth - kWidth(140)) / 3;
    return CGSizeMake(floorf(itemWidth), floorf(itemWidth));
}

@end



@interface MSMomentsContentCell ()
@property (nonatomic) UIImageView *imgV;
@end


@implementation MSMomentsContentCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        self.contentView.backgroundColor = kColor(@"#ffffff");
        
        self.imgV = [[UIImageView alloc] init];
        _imgV.backgroundColor = [UIColor brownColor];
        [self.contentView addSubview:_imgV];
        
        {
            [_imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.contentView);
            }];
        }
        
    }
    return self;
}

@end



