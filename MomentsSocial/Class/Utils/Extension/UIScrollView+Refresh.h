//
//  UIScrollView+Refresh.m
//  PPVideo
//
//  Created by Liang on 16/6/24.
//  Copyright (c) 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIScrollView (Refresh)

- (void)QB_addPullToRefreshWithHandler:(void (^)(void))handler;
- (void)QB_triggerPullToRefresh;
- (void)QB_endPullToRefresh;

- (void)QB_addPagingRefreshWithHandler:(void (^)(void))handler;

- (void)QB_addPagingRefreshWithNotice:(NSString *)notiStr Handler:(void (^)(void))handler;

- (void)QB_pagingRefreshNoMoreData;

- (void)QB_addPagingRefreshWithMomentsVip:(MSLevel)vipLevel Handler:(void (^)(void))handler;

@end
