//
//  MSMomentsCell.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/31.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMomentsCell.h"
#import "MSMomentsContentView.h"

@interface MSMomentsCell ()
@property (nonatomic) UIView      *backView;

@property (nonatomic) UIImageView *userImgV;
@property (nonatomic) UILabel     *nickLabel;
@property (nonatomic) UILabel     *onlineLabel;
@property (nonatomic) UIButton    *greetButton;
@property (nonatomic) UILabel     *contentLabel;

@property (nonatomic) UIImageView *playImgV;
@property (nonatomic) UIImageView *coverImgV;
@property (nonatomic) MSMomentsContentView *photosView;

@property (nonatomic) UIImageView *locationImgV;
@property (nonatomic) UILabel     *locationLabel;

@property (nonatomic) UIButton    *attentionButton;
@property (nonatomic) UIButton    *commentButton;

@property (nonatomic) UIImageView *lineView;

@property (nonatomic) UILabel     *commentLabelA;
@property (nonatomic) UILabel     *commentLabelB;
@end

@implementation MSMomentsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = kColor(@"#f0f0f0");
        self.contentView.backgroundColor = kColor(@"#f0f0f0");
        
        self.backView = [[UIView alloc] init];
        _backView.backgroundColor = kColor(@"#ffffff");
        [self.contentView addSubview:_backView];
        
        self.userImgV = [[UIImageView alloc] init];
        _userImgV.layer.cornerRadius = kWidth(30);
        _userImgV.layer.masksToBounds = YES;
        [_backView addSubview:_userImgV];
        
        self.nickLabel = [[UILabel alloc] init];
        _nickLabel.textColor = kColor(@"#99999");
        _nickLabel.font = kFont(13);
        [_backView addSubview:_nickLabel];
        
        self.onlineLabel = [[UILabel alloc] init];
        _onlineLabel.textColor = kColor(@"#5AC8FA");
        _onlineLabel.font = kFont(12);
        [_backView addSubview:_onlineLabel];
        
        self.greetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_greetButton setTitle:@"打招呼" forState:UIControlStateNormal];
        [_greetButton setTitleColor:kColor(@"#ED465C") forState:UIControlStateNormal];
        _greetButton.titleLabel.font = kFont(12);
        _greetButton.layer.cornerRadius = 3;
        _greetButton.layer.borderColor = kColor(@"#ED465C").CGColor;
        _greetButton.layer.borderWidth = 1.0f;
        _greetButton.layer.masksToBounds = YES;
        [_backView addSubview:_greetButton];
        
        self.contentLabel = [[UILabel alloc] init];
        _contentLabel.textColor = kColor(@"#333333");
        _contentLabel.font = kFont(15);
        _contentLabel.numberOfLines = 0;
        [_backView addSubview:_contentLabel];
        
        self.lineView = [[UIImageView alloc] init];
        _lineView.backgroundColor = kColor(@"#f0f0f0");
        [_backView addSubview:_lineView];
        
        self.locationImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"near_location"]];
        [_backView addSubview:_locationImgV];
        
        self.locationLabel = [[UILabel alloc] init];
        _locationLabel.textColor = kColor(@"#999999");
        _locationLabel.font = kFont(12);
        [_backView addSubview:_locationLabel];
        
        self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commentButton setTitleColor:kColor(@"#999999") forState:UIControlStateNormal];
        _commentButton.titleLabel.font = kFont(12);
        [_commentButton setImage:[UIImage imageNamed:@"moment_comment"] forState:UIControlStateNormal];
        [_backView addSubview:_commentButton];
        
        self.attentionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_attentionButton setTitleColor:kColor(@"#999999") forState:UIControlStateNormal];
        _attentionButton.titleLabel.font = kFont(12);
        [_attentionButton setImage:[UIImage imageNamed:@"near_greeted"] forState:UIControlStateNormal];
        [_backView addSubview:_attentionButton];

        @weakify(self);
        [_attentionButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            if (self.greetAction) {
                self.greetAction();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        [_commentButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            if (self.commentAction) {
                self.commentAction();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        {
            [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.equalTo(self.contentView);
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-kWidth(20));
            }];
            
            [_userImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_backView).offset(kWidth(20));
                make.top.equalTo(_backView).offset(kWidth(22));
                make.size.mas_equalTo(CGSizeMake(kWidth(60), kWidth(60)));
            }];
            
            [_nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_userImgV).offset(kWidth(22));
                make.left.equalTo(_userImgV.mas_right).offset(kWidth(20));
                make.height.mas_equalTo(_nickLabel.font.lineHeight);
            }];
            
            [_onlineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_nickLabel);
                make.left.equalTo(_nickLabel.mas_right).offset(kWidth(22));
                make.height.mas_equalTo(_onlineLabel.font.lineHeight);
            }];
            
            [_greetButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_backView).offset(kWidth(22));
                make.right.equalTo(_backView.mas_right).offset(-kWidth(20));
                make.size.mas_equalTo(CGSizeMake(kWidth(100), kWidth(48)));
            }];
            
            [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_userImgV.mas_bottom).offset(kWidth(20));
                make.left.equalTo(_backView).offset(kWidth(100));
                make.right.equalTo(_backView.mas_right).offset(-kWidth(20));
            }];
        }
        
    }
    return self;
}

- (void)setUserImgUrl:(NSString *)userImgUrl {
    [_userImgV sd_setImageWithURL:[NSURL URLWithString:userImgUrl]];
}

- (void)setNickName:(NSString *)nickName {
    _nickLabel.text = nickName;
}

- (void)setContent:(NSString *)content {
    _contentLabel.text = content;
}

- (void)setLocation:(NSString *)location {
    _locationLabel.text = location;
}

- (void)setCommentsCount:(NSInteger)commentsCount {
    [_commentButton setTitle:[NSString stringWithFormat:@"%ld",(long)commentsCount] forState:UIControlStateNormal];
}

- (void)setAttentionCount:(NSInteger)attentionCount {
    [_attentionButton setTitle:[NSString stringWithFormat:@"%ld",(long)attentionCount] forState:UIControlStateNormal];
}

- (void)setGreeted:(BOOL)greeted {
    _greeted = greeted;
    [_attentionButton setImage:[UIImage imageNamed:greeted ? @"near_greet" : @"near_greeted"] forState:UIControlStateNormal];
}

- (void)setMomentsType:(MSMomentsType)momentsType {
    _momentsType = momentsType;
    if (_photosView) {
        [_photosView removeFromSuperview];
    }
    if (_coverImgV) {
        [_coverImgV removeFromSuperview];
    }
    if (_playImgV) {
        [_playImgV removeFromSuperview];
    }
    

    if (_momentsType == MSMomentsTypePhotos) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsZero;
        self.photosView = [[MSMomentsContentView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [self.contentView addSubview:_photosView];
    } else if (_momentsType == MSMomentsTypeVideo) {
        self.coverImgV = [[UIImageView alloc] init];
        _coverImgV.backgroundColor = [UIColor yellowColor];
        [self.contentView addSubview:_coverImgV];
        
        self.playImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play"]];
        [_coverImgV addSubview:_playImgV];
    }
}

- (void)setDataSource:(id)dataSource {
    if (_momentsType == MSMomentsTypePhotos) {
        _photosView.dataArr = dataSource;
        CGFloat photoheight = (kScreenWidth - kWidth(140))/3;
        NSInteger lineCount = ceilf([(NSArray *)dataSource count] / 3.0);
        CGFloat height = lineCount * photoheight + ((lineCount > 0 ? lineCount : 1) - 1) * kWidth(10);
        [_photosView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentLabel.mas_bottom).offset(kWidth(20));
            make.left.equalTo(_backView).offset(kWidth(100));
            make.right.equalTo(_backView.mas_right).offset(-kWidth(20));
            make.height.mas_equalTo(height);
        }];
        
        [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_photosView.mas_bottom).offset(kWidth(84));
            make.left.equalTo(_backView).offset(kWidth(100));
            make.right.mas_equalTo(_backView.mas_right).offset(-kWidth(20));
            make.height.mas_equalTo(1);
        }];

    } else if (_momentsType == MSMomentsTypeVideo) {
        [_coverImgV sd_setImageWithURL:[NSURL URLWithString:dataSource]];
        CGFloat width = kScreenWidth - kWidth(120);
        [_coverImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentLabel.mas_bottom).offset(kWidth(20));
            make.left.equalTo(_backView).offset(kWidth(100));
            make.right.equalTo(_backView.mas_right).offset(-kWidth(20));
            make.height.mas_equalTo(ceilf(width/2));
        }];
        
        [_playImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_coverImgV);
            make.size.mas_equalTo(CGSizeMake(kWidth(120), kWidth(120)));
        }];
        
        [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_coverImgV.mas_bottom).offset(kWidth(84));
            make.left.equalTo(_backView).offset(kWidth(100));
            make.right.mas_equalTo(_backView.mas_right).offset(-kWidth(20));
            make.height.mas_equalTo(1);
        }];
    }
    
    [_locationImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_lineView.mas_top).offset(-kWidth(26));
        make.left.equalTo(_backView).offset(kWidth(104));
        make.size.mas_equalTo(CGSizeMake(kWidth(24), kWidth(32)));
    }];
    
    [_locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_locationImgV);
        make.left.equalTo(_locationImgV.mas_right).offset(kWidth(12));
        make.height.mas_equalTo(_locationLabel.font.lineHeight);
    }];
    
    [_commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_locationLabel);
        make.right.equalTo(_backView.mas_right).offset(-kWidth(20));
        make.size.mas_equalTo(CGSizeMake(kWidth(90), kWidth(28)));
    }];
    
    [_attentionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_locationLabel);
        make.right.equalTo(_commentButton.mas_left).offset(-kWidth(28));
        make.size.mas_equalTo(CGSizeMake(kWidth(90), kWidth(28)));
    }];
}

- (void)setNickA:(NSString *)nickA {
    _nickA = nickA;
    if (_commentLabelA) {
        [_commentLabelA removeFromSuperview];
    }
    if (_commentLabelB) {
        [_commentLabelB removeFromSuperview];
    }
    self.commentLabelA = [[UILabel alloc] init];
    _commentLabelA.font = kFont(13);
    _commentLabelA.numberOfLines = 0;
    [_backView addSubview:_commentLabelA];
}

- (void)setCommentA:(NSString *)commentA {
    commentA = [NSString stringWithFormat:@"%@:%@",_nickA,commentA];
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:commentA attributes:@{NSForegroundColorAttributeName:kColor(@"#333333"),NSFontAttributeName:kFont(13)}];
    [attriStr addAttributes:@{NSForegroundColorAttributeName:kColor(@"#999999")} range:[commentA rangeOfString:_nickA]];
    _commentLabelA.attributedText = attriStr;
    
    {
        [_commentLabelA mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_backView.mas_left).offset(kWidth(120));
            make.right.equalTo(_backView.mas_right).offset(-kWidth(40));
            make.top.equalTo(_lineView.mas_bottom).offset(kWidth(24));
        }];
    }
}

- (void)setNickB:(NSString *)nickB {
    _nickB = nickB;
    self.commentLabelB = [[UILabel alloc] init];
    _commentLabelB.font = kFont(13);
    _commentLabelB.numberOfLines = 0;
    [_backView addSubview:_commentLabelB];
}

-(void)setCommentB:(NSString *)commentB {
    commentB = [NSString stringWithFormat:@"%@:%@",_nickB,commentB];
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:commentB attributes:@{NSForegroundColorAttributeName:kColor(@"#333333"),NSFontAttributeName:kFont(13)}];
    [attriStr addAttributes:@{NSForegroundColorAttributeName:kColor(@"#999999")} range:[commentB rangeOfString:_nickB]];
    _commentLabelB.attributedText = attriStr;
    
    {
        [_commentLabelB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_backView.mas_left).offset(kWidth(120));
            make.right.equalTo(_backView.mas_right).offset(-kWidth(40));
            make.top.equalTo(_commentLabelA.mas_bottom).offset(kWidth(18));
        }];
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [_commentButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:kWidth(10)];
    [_attentionButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:kWidth(10)];
}

@end
