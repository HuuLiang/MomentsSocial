//
//  UIView+PopAnimation.m
//  YFBFriend
//
//  Created by Liang on 2017/3/9.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "UIView+PopAnimation.h"
#import <POP.h>

static NSString *const kYFBPopSpringAnimationOpacityKeyName         = @"kYFBPopSpringAnimationOpacityKeyName";
static NSString *const kYFBPopSpringAnimationPositionKeyName        = @"kYFBPopSpringAnimationPositionKeyName";
static NSString *const kYFBPopSpringAnimationScaleKeyName           = @"kYFBPopSpringAnimationScaleKeyName";

static NSString *const kYFBPopSpringAnimationTranslationYDownKeyName = @"kYFBPopSpringAnimationTranslationYDownKeyName";
static NSString *const kYFBPopSpringAnimationTranslationYUpKeyName  = @"kYFBPopSpringAnimationTranslationYUpKeyName";

@implementation UIView (PopAnimation)

- (void)hiddenWithPopAnimation {
    
    POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnimation.fromValue = @(1);
    opacityAnimation.toValue = @(0);
    [self.layer pop_addAnimation:opacityAnimation forKey:kYFBPopSpringAnimationOpacityKeyName];
    
//    POPBasicAnimation *positionAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPosition];
//    positionAnimation.fromValue = [NSValue valueWithCGPoint:v];
//    positionAnimation.toValue = [NSValue valueWithCGPoint:HiddenPosition];
//    [self.layer pop_addAnimation:positionAnimation forKey:kYFBPopSpringAnimationPositionKeyName];
    
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    
    scaleAnimation.fromValue  = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
    scaleAnimation.toValue  = [NSValue valueWithCGSize:CGSizeMake(0.5f, 0.5f)];
    [self.layer pop_addAnimation:scaleAnimation forKey:kYFBPopSpringAnimationScaleKeyName];
}

- (void)showWithPopAnimation {
    POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnimation.fromValue = @(0);
    opacityAnimation.toValue = @(1);
    opacityAnimation.beginTime = CACurrentMediaTime() + 0.1;
    [self.layer pop_addAnimation:opacityAnimation forKey:kYFBPopSpringAnimationOpacityKeyName];
    
//    POPBasicAnimation *positionAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPosition];
//    positionAnimation.fromValue = [NSValue valueWithCGPoint:VisibleReadyPosition];
//    positionAnimation.toValue = [NSValue valueWithCGPoint:VisiblePosition];
//    [self.layer pop_addAnimation:positionAnimation forKey:kYFBPopSpringAnimationPositionKeyName];
    
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.fromValue  = [NSValue valueWithCGSize:CGSizeMake(0.5, 0.5f)];
    scaleAnimation.toValue  = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];//@(0.0f);
    scaleAnimation.springBounciness = 20.0f;
    scaleAnimation.springSpeed = 20.0f;
    [self.layer pop_addAnimation:scaleAnimation forKey:kYFBPopSpringAnimationScaleKeyName];
}

- (void)startAnimation {
    POPSpringAnimation * scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.fromValue  = [NSValue valueWithCGSize:CGSizeMake(0.5, 0.5f)];
    scaleAnimation.toValue  = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];//@(0.0f);
    scaleAnimation.springBounciness = 20.0f;
    scaleAnimation.springSpeed = 20.0f;
    [self.layer pop_addAnimation:scaleAnimation forKey:kYFBPopSpringAnimationScaleKeyName];
}

- (void)downAnimation {
    POPSpringAnimation *downAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerTranslationY];
    downAnimation.fromValue = @0;
    downAnimation.toValue = @(kWidth(160));
    downAnimation.springBounciness = 20.0f;
    downAnimation.springSpeed = 20.0f;
    [self.layer pop_addAnimation:downAnimation forKey:kYFBPopSpringAnimationTranslationYDownKeyName];
}

- (void)upAnimation {
    POPSpringAnimation *downAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerTranslationY];
    downAnimation.fromValue = @0;
    downAnimation.toValue = @(-kWidth(160));
    downAnimation.springBounciness = 20.0f;
    downAnimation.springSpeed = 20.0f;
    [self.layer pop_addAnimation:downAnimation forKey:kYFBPopSpringAnimationTranslationYUpKeyName];
}

@end
