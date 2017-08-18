//
//  MSSendMomentHeaderView.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/2.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSSendMomentHeaderView.h"

static NSString *const kMSSendMomentTextViewPlaceholder = @"这一刻的想法";

static NSString *const kMSSendMomentCellReusableIdentifier = @"kMSSendMomentCellReusableIdentifier";

@interface MSSendMomentHeaderView () <UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic) UITextView *textView;
@property (nonatomic) UICollectionView *photosView;
@property (nonatomic) UIImageView *lineV;
@property (nonatomic) UIImageView *locationImgV;
@property (nonatomic) UILabel     *locationLabel;
@property (nonatomic) NSMutableArray <UIImage *> *dataSource;
@end

@implementation MSSendMomentHeaderView
QBDefineLazyPropertyInitialization(NSMutableArray, dataSource)


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        
        self.textView = [[UITextView alloc] init];
        _textView.delegate = self;
        _textView.font = kFont(14);
        _textView.text = kMSSendMomentTextViewPlaceholder;
        _textView.textColor = kColor(@"#9b9b9b");
        _textView.textContainerInset = UIEdgeInsetsMake(kWidth(20), kWidth(40), kWidth(20), kWidth(40));
        [self addSubview:_textView];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = kWidth(10);
        layout.minimumInteritemSpacing = kWidth(10);
        layout.sectionInset = UIEdgeInsetsMake(kWidth(40), kWidth(40), kWidth(40), kWidth(40));
        self.photosView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _photosView.backgroundColor = kColor(@"#ffffff");
        _photosView.delegate = self;
        _photosView.dataSource = self;
        [_photosView registerClass:[MSSendMomentCell class] forCellWithReuseIdentifier:kMSSendMomentCellReusableIdentifier];
        [self addSubview:_photosView];
        
        self.lineV = [[UIImageView alloc] init];
        _lineV.backgroundColor = kColor(@"#D6D9D8");
        [self addSubview:_lineV];
        
        _locationImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"near_location"]];
        [self addSubview:_locationImgV];
        
        self.locationLabel = [[UILabel alloc] init];
        _locationLabel.textColor = kColor(@"#999999");
        _locationLabel.font = kFont(14);
        [self addSubview:_locationLabel];
        
        {
            [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.right.equalTo(self);
                make.height.mas_equalTo(kWidth(170));
            }];
            
            [_photosView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(_textView.mas_bottom);
                make.size.mas_equalTo(CGSizeMake(kScreenWidth, kWidth(240)));
            }];
            
            [_lineV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(_photosView.mas_bottom);
                make.size.mas_equalTo(CGSizeMake(kScreenWidth, 1));
            }];
            
            [_locationImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_lineV.mas_bottom).offset(kWidth(26));
                make.left.equalTo(self).offset(kWidth(30));
                make.size.mas_equalTo(CGSizeMake(kWidth(24), kWidth(32)));
            }];
            
            [_locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_locationImgV);
                make.left.equalTo(_locationImgV.mas_right).offset(kWidth(16));
                make.height.mas_equalTo(_locationLabel.font.lineHeight);
            }];
        }
    }
    return self;
}

- (void)setAddImg:(UIImage *)addImg {
    [self.dataSource addObject:addImg];
    [self.photosView reloadData];
}

- (NSInteger)photoCount {
    NSInteger allCount = _dataSource.count + 1;
    NSInteger lineCount = allCount % 4 == 0 ? allCount / 4 : allCount/4 + 1;
    if (lineCount > 1) {
        CGFloat addHeight = (kScreenWidth - kWidth(110))/4 * (lineCount - 1);
        [_photosView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kScreenWidth, kWidth(240) + addHeight));
        }];
    }

    return _dataSource.count + 1;
}

- (void)setLocation:(NSString *)location {
    _locationLabel.text = location;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:kMSSendMomentTextViewPlaceholder]) {
        textView.text = @"";
        textView.textColor = kColor(@"#333333");
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length < 1) {
        textView.text = kMSSendMomentTextViewPlaceholder;
        textView.textColor = kColor(@"#9B9B9B");
    }
}

#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MSSendMomentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMSSendMomentCellReusableIdentifier forIndexPath:indexPath];
    if (indexPath.item < self.dataSource.count + 1) {
        if (indexPath.item == 0) {
            cell.img = [UIImage imageNamed:@"moment_add"];
        } else {
            cell.img = self.dataSource[indexPath.item - 1];

        }
        return cell;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (CGRectGetWidth(collectionView.frame) - kWidth(110))/4;
    return CGSizeMake(floorf(width), floorf(width));
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        if (self.getPhotoAction) {
            self.getPhotoAction();
        }
    }
}

@end


@interface MSSendMomentCell ()
@property (nonatomic) UIImageView *imgV;
@end


@implementation MSSendMomentCell

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
    }
    return self;
}

- (void)setImg:(UIImage *)img {
    _imgV.image = img;
}

@end

