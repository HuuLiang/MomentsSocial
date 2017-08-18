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
        
        self.backgroundColor = kColor(@"#ffffff");
        layout.minimumLineSpacing = kWidth(10);
        layout.minimumInteritemSpacing = kWidth(10);
        self.collectionViewLayout = layout;
        [self registerClass:[MSMomentsContentCell class] forCellWithReuseIdentifier:kMSMomentsCellReusableIdentifier];
        
    }
    return self;
}

- (void)setVipLevel:(MSLevel)vipLevel {
    _vipLevel = vipLevel;
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
        if ([MSUtil currentVipLevel] <= _vipLevel && indexPath.item > 2) {
            cell.needBlur = YES;
        } else {
            cell.needBlur = NO;
        }
        cell.imgUrl = self.mutableArr[indexPath.item];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = (kScreenWidth - kWidth(140)) / 3;
    return CGSizeMake(floorf(itemWidth), floorf(itemWidth));
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.browserAction) {
        self.browserAction(@(indexPath.item));
    }
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
        [self.contentView addSubview:_imgV];
        
        {
            [_imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.contentView);
            }];
        }
        
//        @weakify(self);
//        [_imgV aspect_hookSelector:@selector(setNeedsLayout) withOptions:AspectPositionAfter usingBlock:^(id <AspectInfo> AspectInfo) {
//            @strongify(self);
//            dispatch_async(dispatch_queue_create(0, 0), ^{
//                UIImageView *targetImgV = (UIImageView *)[AspectInfo instance];
//                UIImage *image = targetImgV.image;
//                if (image && self.needBlur) {
//                    UIImage *blurImage = image.boxBlurImage;
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        targetImgV.image = blurImage;
//                    });
//                }
//            });
//        } error:nil];
    }
    return self;
}

- (void)setNeedBlur:(BOOL)needBlur {
    _needBlur = needBlur;
}

- (void)setImgUrl:(NSString *)imgUrl {
    @weakify(self);
    [_imgV sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:nil options:SDWebImageAvoidAutoSetImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        @strongify(self);
        if (image) {
//            UIImage *blurImage = image.boxBlurImage;
            self.imgV.image = self.needBlur ? image.boxBlurImage : image;
        }
    }];
}

@end



