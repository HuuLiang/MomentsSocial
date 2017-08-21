//
//  MSRollView.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/19.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSRollView.h"

@interface MSRollView ()
@property (nonatomic) UIImageView *imgV;
@property (nonatomic) UIView *backView;
@property (nonatomic) dispatch_source_t timer;
@property (nonatomic) NSInteger currentIndex;
@end

@implementation MSRollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
//        self.layer.cornerRadius = frame.size.width/2;
//        self.layer.masksToBounds = YES;
        
        self.backView = [[UIView alloc] init];
        _backView.backgroundColor = kColor(@"#ffffff");
        _backView.layer.cornerRadius = frame.size.width/2;
        _backView.layer.masksToBounds = YES;
        [self addSubview:_backView];
        
        self.imgV = [[UIImageView alloc] init];
        _imgV.layer.cornerRadius = frame.size.width/2-1.5;
        _imgV.layer.masksToBounds = YES;
        [_backView addSubview:_imgV];
        
        {
            [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            
            [_imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.size.mas_equalTo(CGSizeMake(frame.size.width - 3, frame.size.height - 3));
            }];
        }
        
    }
    return self;
}

- (void)setImgUrls:(NSArray *)imgUrls {
    _imgUrls = imgUrls;
    if (_imgUrls.count > 0) {
        _currentIndex = 0;
        [_imgV sd_setImageWithURL:[NSURL URLWithString:_imgUrls[_currentIndex]]];
        if (_imgUrls.count > 1) {
            [self startAutoRoll];
        }
    }
}

- (void)startAutoRoll {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 5 * NSEC_PER_SEC, 0); // 每5S
    dispatch_source_set_event_handler(_timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self timerRepeat];
        });
    });
    dispatch_resume(_timer);
}

- (void)timerRepeat {
    NSInteger nextIndex = _currentIndex + 1;
    
    if (nextIndex == self.imgUrls.count) {
        nextIndex = 0;
    }
    
    
    [UIView animateWithDuration:1 animations:^{
        self.backView.layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 1, 0);
    } completion:^(BOOL finished) {
        [_imgV sd_setImageWithURL:[NSURL URLWithString:self.imgUrls[nextIndex]]];
        _currentIndex = nextIndex;
        [UIView animateWithDuration:1 animations:^{
            self.backView.layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 0);
        } completion:^(BOOL finished) {
            self.backView.layer.transform = CATransform3DIdentity;
        }];
    }];
}

@end
