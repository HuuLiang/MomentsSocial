//
//  MSDetailPhotoCell.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/1.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSDetailPhotoCell.h"

@interface MSDetailPhotoCell ()
@property (nonatomic) UIImageView *imgV;
@end

@implementation MSDetailPhotoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
//        self.contentView.backgroundColor = kColor(@"#ffffff");
        self.contentView.backgroundColor = [UIColor blueColor];
        
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

- (void)setImgUrl:(NSString *)imgUrl {
    [_imgV sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
}

@end
