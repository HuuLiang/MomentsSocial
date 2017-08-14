//
//  QBPhotoBrowser.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "QBPhotoBrowser.h"
#import "SDCycleScrollView.h"


@interface QBPhotoBrowser () <SDCycleScrollViewDelegate>
@property (nonatomic,strong) SDCycleScrollView *photoScrollView;
@property (nonatomic) BOOL needBlur;
@property (nonatomic) NSInteger blurIndex;
@property (nonatomic) BrowseHandler handler;
@end

@implementation QBPhotoBrowser

+ (instancetype)browse {
    static QBPhotoBrowser *_browse;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _browse = [[QBPhotoBrowser alloc] init];
    });
    return _browse;
}

- (void)showPhotoBrowseWithImageUrl:(NSArray *)imageUrls
                            atIndex:(NSInteger)currentIndex
                           needBlur:(BOOL)needBlur
                     blurStartIndex:(NSInteger)blurStartIndex
                        onSuperView:(UIView *)superView
                            handler:(BrowseHandler)handler{
    _needBlur = needBlur;
    _blurIndex = blurStartIndex;
    _handler = handler;
    
    superView = [MSUtil rootViewControlelr].view;
    
    self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    [superView addSubview:self];
    
    self.photoScrollView = [SDCycleScrollView cycleScrollViewWithFrame:self.bounds imageURLStringsGroup:imageUrls];
    _photoScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFit;
    _photoScrollView.backgroundColor = [UIColor blackColor];
    _photoScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    _photoScrollView.autoScroll = NO;
    _photoScrollView.infiniteLoop = NO;
    _photoScrollView.pageDotColor = [UIColor colorWithHexString:@"#D8D8D8"];
    _photoScrollView.currentPageDotColor = [UIColor colorWithHexString:@"#FF206F"];
    _photoScrollView.delegate = self;
    _photoScrollView.isNeedBlur = needBlur;
    _photoScrollView.startBlurIndex = blurStartIndex;
    if (imageUrls[currentIndex]) {
        _photoScrollView.currentPage = currentIndex;
    }
    
    [self addSubview:_photoScrollView];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
    }];
    if (needBlur && currentIndex >= blurStartIndex) {
        [self performSelector:@selector(popNoticeView) withObject:nil afterDelay:0.5];
    }
}

- (void)popNoticeView {
    if (self.handler) {
        self.handler();
    }
}

- (void)closeBrowse {
    if (self.closeAction) {
        self.closeAction(self);
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [_photoScrollView removeFromSuperview];
        _photoScrollView = nil;
    }];
}

#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    [self closeBrowse];
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index {
    if (self.needBlur && index >= self.blurIndex) {
        if (self.handler) {
            self.handler();
        }
    }
}

@end
