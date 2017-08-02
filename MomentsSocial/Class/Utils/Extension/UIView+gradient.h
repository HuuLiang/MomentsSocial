//
//  UIView+gradient.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/27.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int,GradientType) {
    topToBottom = 0,//从上到小
    leftToRight = 1,//从左到右
    upleftTolowRight = 2,//左上到右下
    uprightTolowLeft = 3,//右上到左下
};

@interface UIView (gradient)

- (UIImage *)setGradientWithSize:(CGSize)size Colors:(NSArray <UIColor *> *)colors direction:(GradientType)gradientType;

@end
