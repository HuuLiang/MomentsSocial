//
//  UIImage+Blur.h
//  JYFriend
//
//  Created by ylz on 2017/1/19.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Blur)

- (UIImage*)blurImage;

- (UIImage*)otherBlurImage;

- (UIImage *)boxBlurImage;

- (UIImage *)smallBlurImage;
@end
