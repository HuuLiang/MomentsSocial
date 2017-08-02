//
//  UIImage+Blur.m
//  JYFriend
//
//  Created by ylz on 2017/1/19.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "UIImage+Blur.h"
#import <Accelerate/Accelerate.h>

@implementation UIImage (Blur)

- (UIImage*)blurWithIsSmallPicture:(BOOL)isSmall
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    CGFloat blur ;
    if (isSmall) {
        blur = self.size.height * 0.06;
    }else {
        blur = self.size.height *0.04;
    }
    [filter setValue:[NSNumber numberWithFloat:blur] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return returnImage;
}


@end
