//
//  NSString+Size.h
//  HuangDuanZi
//
//  Created by ZF on 16/3/14.
//  Copyright © 2016年 ZF. All rights reserved.
//  根据文本字体和文字计算label的高度

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (Size)
- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)maxW;
- (CGSize)sizeWithFont:(UIFont *)font;
- (CGSize)sizeWithFont:(UIFont *)font maxHeight:(CGFloat)maxH;
@end
