//
//  UIView+GeometryMetrics.h
//  FunTuYing
//
//  Created by Sean Yue on 2017/6/17.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (GeometryMetrics)

@property (nonatomic,readonly) CGFloat GM_width;
@property (nonatomic,readonly) CGFloat GM_height;
@property (nonatomic,readonly) CGSize GM_size;

@property (nonatomic,readonly) CGFloat GM_left;  //minX
@property (nonatomic,readonly) CGFloat GM_right; //maxX
@property (nonatomic,readonly) CGFloat GM_top;   //minY
@property (nonatomic,readonly) CGFloat GM_bottom; //maxY

@property (nonatomic,readonly) CGFloat GM_centerX;
@property (nonatomic,readonly) CGFloat GM_centerY;
@property (nonatomic,readonly) CGPoint GM_boundsCenter;

//- (CGPoint)GM_originPointForViewWithSize:(CGSize)size
@end
