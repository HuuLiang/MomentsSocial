//
//  UIButton+iconSpacing.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/28.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MKButtonEdgeInsetsStyle) {
    MKButtonEdgeInsetsStyleTop, // image在上，label在下
    MKButtonEdgeInsetsStyleLeft, // image在左，label在右
    MKButtonEdgeInsetsStyleBottom, // image在下，label在上
    MKButtonEdgeInsetsStyleRight // image在右，label在左
};

@interface UIButton (iconSpacing)

///** 图片在左，标题在右 */
//- (void)setIconInLeft;
///** 图片在右，标题在左 */
//- (void)setIconInRight;
///** 图片在上，标题在下 */
//- (void)setIconInTop;
///** 图片在下，标题在上 */
//- (void)setIconInBottom;
//
////** 可以自定义图片和标题间的间隔 */
//- (void)setIconInLeftWithSpacing:(CGFloat)Spacing;
//- (void)setIconInRightWithSpacing:(CGFloat)Spacing;
//- (void)setIconInTopWithSpacing:(CGFloat)Spacing;
//- (void)setIconInBottomWithSpacing:(CGFloat)Spacing;

/**
 *  设置button的titleLabel和imageView的布局样式，及间距
 *
 *  @param style titleLabel和imageView的布局样式
 *  @param space titleLabel和imageView的间距
 */
- (void)layoutButtonWithEdgeInsetsStyle:(MKButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space;

@end
