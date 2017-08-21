//
//  MSHomeCategoryCell.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/27.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSHomeCategoryCell.h"
#import "MSScrollLabel.h"
#import "MSRollView.h"
#import "FXBlurView.h"

@interface MSHomeCategoryCell ()
@property (nonatomic) UIImageView *backImgV;
@property (nonatomic) UIImageView *shadowImgV;
//@property (nonatomic) FXBlurView  *blurView;
@property (nonatomic) MSRollView  *rollImgV;
@property (nonatomic) UIImageView *centerImgV;
@property (nonatomic) UILabel     *titleLabel;
@property (nonatomic) MSScrollLabel *scrollLabel;
@end

@implementation MSHomeCategoryCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        self.contentView.backgroundColor = kColor(@"#ffffff");
        
        self.backImgV = [[UIImageView alloc] init];
        _backImgV.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_backImgV];
        
//        self.blurView = [[FXBlurView alloc] initWithFrame:frame];
//        self.blurView.updateInterval = 1 /60.;
//        [_blurView setBlurRadius:40];
////        self.blurView.tintColor = [UIColor colorWithRed:0 green:0.5 blue:0.5 alpha:1];
//        [self.contentView addSubview:_blurView];
//        [_blurView updateAsynchronously:NO completion:^{
//            
//            _blurView.frame = self.bounds;
//        }];
//        _blurView.hidden = YES;
        
        self.shadowImgV = [[UIImageView alloc] init];
        [self.contentView addSubview:_shadowImgV];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kColor(@"#ffffff");
        _titleLabel.font = kFont(15);
        [self.contentView addSubview:_titleLabel];
        
        self.scrollLabel = [[MSScrollLabel alloc] initWithFrame:CGRectMake(0, frame.size.height - kWidth(60), frame.size.width, kWidth(30))];
        [self.contentView addSubview:_scrollLabel];
        
        self.centerImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_star"]];
        [self.contentView addSubview:_centerImgV];
        _centerImgV.hidden = YES;
        
        self.rollImgV = [[MSRollView alloc] initWithFrame:CGRectMake(0, 0, kWidth(108), kWidth(108))];
        [self.contentView addSubview:_rollImgV];
        _rollImgV.hidden = YES;
        
        {
            [_backImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.contentView);
            }];
            
            [_shadowImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.contentView);
            }];
            
//            [_blurView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.edges.equalTo(self.contentView);
//            }];
            
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.contentView);
                make.bottom.equalTo(_scrollLabel.mas_top).offset(-kWidth(16));
                make.height.mas_equalTo(_titleLabel.font.lineHeight);
            }];
            
            [_centerImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.contentView);
                make.bottom.equalTo(_titleLabel.mas_top).offset(-kWidth(20));
                make.size.mas_equalTo(CGSizeMake(kWidth(84) , kWidth(74)));
            }];
            
            [_rollImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.contentView);
                make.bottom.equalTo(_titleLabel.mas_top).offset(-kWidth(20));
                make.size.mas_equalTo(CGSizeMake(kWidth(108) , kWidth(108)));
            }];
        }
    }
    return self;
}

- (void)setBackUrl:(NSString *)backUrl {
    @weakify(self);
    [_backImgV sd_setImageWithURL:[NSURL URLWithString:backUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        @strongify(self);
        if (_circleType == MSCircleTypeBlur) {
            _backImgV.image = nil;
            if (image.images.count > 0) {
                self.backImgV.image = image.images[0].otherBlurImage;
                NSMutableArray *blurImgs = [NSMutableArray array];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [image.images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [blurImgs addObject:obj.otherBlurImage];
                    }];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.backImgV setAnimationImages:blurImgs];
                        [self.backImgV setAnimationDuration:2];
                        self.backImgV.animationRepeatCount = 0;
                        [self.backImgV startAnimating];
                    });
                });
            }
        }
    }];
}

- (void)setCoverImgUrl:(NSString *)coverImgUrl {
    _coverImgUrl = coverImgUrl;
}

- (void)setImgsUrl:(NSArray *)imgsUrl {
    _imgsUrl = imgsUrl;
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setTitles:(NSArray *)titles {
    _titles = titles;
}

- (void)setVipLevel:(MSLevel)vipLevel {
    _vipLevel = vipLevel;
}

- (void)setCircleType:(MSCircleType)circleType {
    _circleType = circleType;
    _shadowImgV.image = nil;
    _centerImgV.hidden = YES;
    _rollImgV.hidden = YES;
//    _blurView.hidden = YES;
    if (circleType == MSCircleTypeNone) {
        _shadowImgV.backgroundColor = [kColor(@"#000000") colorWithAlphaComponent:0.25];
        
    } else if (circleType == MSCircleTypeBlur) {
//        _blurView.hidden = NO;
//        _blurView.tintColor = [kColor(@"#A538BC") colorWithAlphaComponent:0.45];
        
        _shadowImgV.backgroundColor = [kColor(@"#A538BC") colorWithAlphaComponent:0.45];
//        _shadowImgV.hidden = YES;
    } else if (circleType == MSCircleTypeCover) {
        _centerImgV.hidden = NO;
        [_shadowImgV sd_setImageWithURL:[NSURL URLWithString:_coverImgUrl]];
        
    } else if (circleType == MSCircleTypeScroll) {
        _rollImgV.hidden = NO;
        [_shadowImgV sd_setImageWithURL:[NSURL URLWithString:_coverImgUrl]];
        _rollImgV.imgUrls = _imgsUrl;
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    _scrollLabel.titlesArr = _titles;
}

@end
