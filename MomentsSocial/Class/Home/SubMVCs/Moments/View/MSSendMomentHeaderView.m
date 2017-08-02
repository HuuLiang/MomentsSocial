//
//  MSSendMomentHeaderView.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/2.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSSendMomentHeaderView.h"

FOUNDATION_EXPORT NSString *const kMSSendMomentTextViewPlaceholder;
NSString *const kMSSendMomentTextViewPlaceholder = @"这一刻的想法";

@interface MSSendMomentHeaderView () <UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic) UITextView *textView;
@property (nonatomic) UICollectionView *photosView;
@property (nonatomic) UIImageView *lineV;
@property (nonatomic) UIImageView *locationImgV;
@property (nonatomic) UILabel     *locationLabel;
@end

@implementation MSSendMomentHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        
        self.textView = [[UITextView alloc] init];
        _textView.delegate = self;
        _textView.font = kFont(14);
        _textView.textContainerInset = UIEdgeInsetsMake(kWidth(20), kWidth(40), kWidth(20), kWidth(40));
        [self addSubview:_textView];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = kWidth(10);
        layout.minimumInteritemSpacing = kWidth(10);
        layout.sectionInset = UIEdgeInsetsMake(kWidth(40), kWidth(40), kWidth(40), kWidth(40));
        layout.itemSize = CGSizeMake(kWidth(160), kWidth(160));
        self.photosView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _photosView.backgroundColor = kColor(@"#ffffff");
        _photosView.delegate = self;
        _photosView.dataSource = self;
        self
        
        {
            [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.right.equalTo(self);
                make.height.mas_equalTo(kWidth(170));
            }];
        }
        
        
    }
    return self;
}


#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.text == kMSSendMomentTextViewPlaceholder) {
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

