//
//  UIScrollView+Refresh.m
//  PPVideo
//
//  Created by Liang on 16/6/4.
//  Copyright (c) 2016年 iqu8. All rights reserved.
//

#import "UIScrollView+Refresh.h"
#import <MJRefresh.h>

@implementation UIScrollView (Refresh)

- (void)QB_addPullToRefreshWithHandler:(void (^)(void))handler {
    if (!self.mj_header) {
        MJRefreshNormalHeader *refreshHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:handler];
        refreshHeader.lastUpdatedTimeLabel.hidden = YES;
        self.mj_header = refreshHeader;
    }
}

- (void)QB_triggerPullToRefresh {
    [self.mj_header beginRefreshing];
}

- (void)QB_endPullToRefresh {
    [self.mj_header endRefreshing];
    [self.mj_footer resetNoMoreData];
}

- (void)QB_addPagingRefreshWithHandler:(void (^)(void))handler {
    if (!self.mj_footer) {
        MJRefreshAutoNormalFooter *refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:handler];
        self.mj_footer = refreshFooter;
    }
}

- (void)QB_addPagingRefreshWithNotice:(NSString *)notiStr Handler:(void (^)(void))handler {
    if (!self.mj_footer) {
        MJRefreshAutoNormalFooter *refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:handler];
        [refreshFooter setTitle:notiStr forState:MJRefreshStateIdle];
        self.mj_footer = refreshFooter;
    }
}

- (void)QB_addPagingRefreshWithMomentsVip:(MSLevel)vipLevel Handler:(void (^)(void))handler {
    NSString *notiStr = nil;
    if ([MSUtil currentVipLevel] == MSLevelVip0) {
        notiStr = @"升级VIP,查看更多动态！";
    } else {
        notiStr = @"------  我是有底线的  ------";
    }
    if (!self.mj_footer) {
        MJRefreshAutoNormalFooter *refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:handler];
        [refreshFooter setTitle:notiStr forState:MJRefreshStateIdle];
        self.mj_footer = refreshFooter;
    }
}

- (void)QB_pagingRefreshNoMoreData {
    [self.mj_footer endRefreshingWithNoMoreData];
}



@end
