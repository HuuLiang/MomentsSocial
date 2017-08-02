//
//  NSString+Size.m
//  HuangDuanZi
//
//  Created by ZF on 16/3/14.
//  Copyright © 2016年 ZF. All rights reserved.
//

#import "NSString+Size.h"

@implementation NSString (Size)
-(CGSize)sizeWithFont:(UIFont *)font{

    return  [self sizeWithFont:font maxWidth:MAXFLOAT];

}

- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)maxW{

    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = font;
    CGSize maxSize = CGSizeMake(maxW, MAXFLOAT);

    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attrs context:nil].size;
}

- (CGSize)sizeWithFont:(UIFont *)font maxHeight:(CGFloat)maxH {
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = font;
    CGSize maxSize = CGSizeMake(MAXFLOAT, maxH);
    
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attrs context:nil].size;
}

@end
