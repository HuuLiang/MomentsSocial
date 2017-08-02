//
//  UIImage+QBResource.h
//  Pods
//
//  Created by Sean Yue on 16/7/1.
//
//

#import <Foundation/Foundation.h>

@interface UIImage (Resource)

+ (instancetype)imageWithResourcePath:(NSString *)imagePath; // ofType = @"png"
+ (instancetype)imageWithResourcePath:(NSString *)imagePath ofType:(NSString *)type;

@end
