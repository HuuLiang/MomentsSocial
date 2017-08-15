//
//  MSCheckInFooterView.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/3.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSCheckInFooterView.h"
#import "FLAnimatedImageView.h"

@interface MSCheckInFooterView ()
@property FLAnimatedImageView *imgV;
@end

@implementation MSCheckInFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = kColor(@"#ffffff");
        
        
        self.imgV = [[FLAnimatedImageView alloc] init];
        _imgV.backgroundColor = kColor(@"#000000");
        [self addSubview:_imgV];
        
        {
            [_imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.size.mas_equalTo(CGSizeMake(kWidth(706), kWidth(376)));
            }];
        }
    }
    return self;
}

- (void)setImgUrl:(NSString *)imgUrl {
    [_imgV sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
}

@end

