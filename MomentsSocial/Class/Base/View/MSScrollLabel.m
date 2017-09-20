//
//  MSScrollLabel.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/18.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSScrollLabel.h"

@interface MSScrollLabel ()
@property (nonatomic,strong) dispatch_source_t timer;
@property (nonatomic) UILabel *topLabel;
@property (nonatomic) UILabel *bottomLabel;
@property (nonatomic) NSInteger currentIndex;
@end

@implementation MSScrollLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = YES;
        
        self.bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, frame.size.height)];
        _bottomLabel.textColor = [kColor(@"#ffffff") colorWithAlphaComponent:0.75];
        _bottomLabel.font = kFont(12);
        _bottomLabel.backgroundColor = [UIColor clearColor];
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_bottomLabel];
        
        self.topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _topLabel.textColor = [kColor(@"#ffffff") colorWithAlphaComponent:0.75];
        _topLabel.font = kFont(12);
        _topLabel.backgroundColor = [UIColor clearColor];
        _topLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_topLabel];
        
    }
    return self;
}

- (void)setTitlesArr:(NSArray *)titlesArr {
    _titlesArr = titlesArr;
    if (_titlesArr.count > 0) {
        _currentIndex = 0;
        _topLabel.text = _titlesArr[_currentIndex];
        [self startAutoScroll];
    }
}

- (void)startAutoScroll {
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
    NSInteger bottomIndex = _currentIndex + 1;
    
    if (bottomIndex >= self.titlesArr.count) {
        bottomIndex = 0;
    }
    
//    QBLog(@" bottomIndex =  %ld,title = %@",bottomIndex,_titlesArr[bottomIndex]);
    _bottomLabel.text = self.titlesArr[bottomIndex];
    
    CGFloat moveHeight = self.frame.size.height;
    
    [UIView animateWithDuration:1 animations:^{
        _topLabel.transform = CGAffineTransformMakeTranslation(0, -moveHeight);
        _bottomLabel.transform = CGAffineTransformMakeTranslation(0, -moveHeight);
    } completion:^(BOOL finished) {
        _topLabel.text = self.titlesArr[bottomIndex];
        _topLabel.transform = CGAffineTransformIdentity;
        _bottomLabel.text = @"";
        _bottomLabel.transform = CGAffineTransformIdentity;
        _currentIndex = bottomIndex;
    }];
}

@end
