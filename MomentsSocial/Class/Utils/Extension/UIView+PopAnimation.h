//
//  UIView+PopAnimation.h
//  YFBFriend
//
//  Created by Liang on 2017/3/9.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PopAnimation)

- (void)hiddenWithPopAnimation;

- (void)showWithPopAnimation;

- (void)startAnimation;

- (void)stopAnimation;

- (void)downAnimation;

- (void)upAnimation;

@end
