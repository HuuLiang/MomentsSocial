//
//  UIButton+iconSpacing.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/28.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "UIButton+iconSpacing.h"

@implementation UIButton (iconSpacing)
//
//- (void)setIconInLeft
//{
//    [self setIconInLeftWithSpacing:0];
//}
//
//- (void)setIconInRight
//{
//    [self setIconInRightWithSpacing:0];
//}
//
//- (void)setIconInTop
//{
//    [self setIconInTopWithSpacing:0];
//}
//
//- (void)setIconInBottom
//{
//    [self setIconInBottomWithSpacing:0];
//}
//
//- (void)setIconInLeftWithSpacing:(CGFloat)Spacing
//{
//    self.titleEdgeInsets = (UIEdgeInsets){
//        .top    = 0,
//        .left   = Spacing/2,
//        .bottom = 0,
//        .right  = -Spacing/2,
//    };
//    
//    self.imageEdgeInsets = (UIEdgeInsets){
//        .top    = 0,
//        .left   = -Spacing/2,
//        .bottom = 0,
//        .right  = Spacing/2,
//    };
//}
//
//- (void)setIconInRightWithSpacing:(CGFloat)Spacing
//{
//    CGFloat img_W = self.imageView.frame.size.width;
//    CGFloat tit_W = self.titleLabel.frame.size.width;
//    
//    self.titleEdgeInsets = (UIEdgeInsets){
//        .top    = 0,
//        .left   = - (img_W + Spacing / 2),
//        .bottom = 0,
//        .right  =   (img_W + Spacing / 2),
//    };
//    
//    self.imageEdgeInsets = (UIEdgeInsets){
//        .top    = 0,
//        .left   =   (tit_W + Spacing / 2),
//        .bottom = 0,
//        .right  = - (tit_W + Spacing / 2),
//    };
//}
//
//- (void)setIconInTopWithSpacing:(CGFloat)Spacing
//{
//    CGFloat img_W = self.imageView.frame.size.width;
//    CGFloat img_H = self.imageView.frame.size.height;
//    CGFloat tit_W = self.titleLabel.frame.size.width;
//    CGFloat tit_H = self.titleLabel.frame.size.height;
//    
//    self.titleEdgeInsets = (UIEdgeInsets){
//        .top    =   (tit_H / 2 + Spacing / 2),
//        .left   = - (img_W / 2),
//        .bottom = - (tit_H / 2 + Spacing / 2),
//        .right  =   (img_W / 2),
//    };
//    
//    self.imageEdgeInsets = (UIEdgeInsets){
//        .top    = - (img_H / 2 + Spacing / 2),
//        .left   =   (tit_W / 2),
//        .bottom =   (img_H / 2 + Spacing / 2),
//        .right  = - (tit_W / 2),
//    };
//}
//
//- (void)setIconInBottomWithSpacing:(CGFloat)Spacing
//{
//    CGFloat img_W = self.imageView.frame.size.width;
//    CGFloat img_H = self.imageView.frame.size.height;
//    CGFloat tit_W = self.titleLabel.frame.size.width;
//    CGFloat tit_H = self.titleLabel.frame.size.height;
//    
//    self.titleEdgeInsets = (UIEdgeInsets){
//        .top    = - (tit_H / 2 + Spacing / 2),
//        .left   = - (img_W / 2),
//        .bottom =   (tit_H / 2 + Spacing / 2),
//        .right  =   (img_W / 2),
//    };
//    
//    self.imageEdgeInsets = (UIEdgeInsets){
//        .top    =   (img_H / 2 + Spacing / 2),
//        .left   =   (tit_W / 2),
//        .bottom = - (img_H / 2 + Spacing / 2),
//        .right  = - (tit_W / 2),
//    };
//}
//


- (void)layoutButtonWithEdgeInsetsStyle:(MKButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space
{
    // 1. 得到imageView和titleLabel的宽、高
    CGFloat imageWith = self.imageView.frame.size.width;
    CGFloat imageHeight = self.imageView.frame.size.height;
    
    CGFloat labelWidth = 0.0;
    CGFloat labelHeight = 0.0;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        // 由于iOS8中titleLabel的size为0，用下面的这种设置
        labelWidth = self.titleLabel.intrinsicContentSize.width;
        labelHeight = self.titleLabel.intrinsicContentSize.height;
    } else {
        labelWidth = self.titleLabel.frame.size.width;
        labelHeight = self.titleLabel.frame.size.height;
    }
    
    // 2. 声明全局的imageEdgeInsets和labelEdgeInsets
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
    
    // 3. 根据style和space得到imageEdgeInsets和labelEdgeInsets的值
    switch (style) {
        case MKButtonEdgeInsetsStyleTop:
        {
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-space/2.0, 0, 0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-space/2.0, 0);
        }
            break;
        case MKButtonEdgeInsetsStyleLeft:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0);
        }
            break;
        case MKButtonEdgeInsetsStyleBottom:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight-space/2.0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight-space/2.0, -imageWith, 0, 0);
        }
            break;
        case MKButtonEdgeInsetsStyleRight:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+space/2.0, 0, -labelWidth-space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith-space/2.0, 0, imageWith+space/2.0);
        }
            break;
        default:
            break;
    }
    // 4. 赋值
    self.titleEdgeInsets = labelEdgeInsets;
    self.imageEdgeInsets = imageEdgeInsets;
}



@end
