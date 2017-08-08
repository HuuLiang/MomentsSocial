//
//  YFBImageUploadManager.m
//  YFBFriend
//
//  Created by Liang on 2017/4/11.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "YFBImageUploadManager.h"
#import <AFNetworking.h>
#import "QiniuToken.h"
#import "QiniuUploader.h"

@interface YFBImageUploadManager ()
@property (nonatomic) NSString *accessToken;
@end

@implementation YFBImageUploadManager

+ (void)registerWithSecretKey:(NSString *)secretKey accessKey:(NSString *)accessKey scope:(NSString *)scope {
    [QiniuToken registerWithScope:scope SecretKey:secretKey Accesskey:accessKey TimeToLive:3600];
}

+ (NSString *)imageURLWithName:(NSString *)name {
    NSString *baseURL = @"http://mfw.jtd51.com";
    if (![baseURL hasSuffix:@"/"]) {
        baseURL = [baseURL stringByAppendingString:@"/"];
    }
    
    return [baseURL stringByAppendingString:name];
}

+ (BOOL)uploadImage:(UIImage *)image
           withName:(NSString *)name
  completionHandler:(QBCompletionHandler)handler
{
    QiniuUploader *uploader = [[QiniuUploader alloc] init];
    
    uploader.uploadOneFileSucceeded = ^(NSInteger index, NSString * _Nonnull key, NSDictionary * _Nonnull info) {
        QBSafelyCallBlock(handler,YES,[self imageURLWithName:key]);
    };
    
    uploader.uploadOneFileFailed = ^(NSInteger index, NSError * _Nullable error) {
        QBSafelyCallBlock(handler,NO,error);
    };
    
    uploader.uploadOneFileProgress = ^(NSInteger index, NSProgress * _Nonnull process) {
        QBLog(@"%@",process);
    };
    
    
    [self uploader:uploader addImage:image withName:name];
    NSString *acccessToken = [[QiniuToken sharedQiniuToken] uploadToken];
    return [uploader startUploadWithAccessToken:acccessToken];
}

+ (void)uploader:(QiniuUploader *)uploader addImage:(UIImage *)image withName:(NSString *)name {
    const CGFloat widthMetrics = 736;
    const CGFloat heightMetrics = 414;
    const CGFloat compressionQuality = MIN(1, MAX(widthMetrics/image.size.width, heightMetrics/image.size.height));
    
    NSData *imageData;
    if ([name hasSuffix:@".png"]) {
        imageData = UIImagePNGRepresentation(image);
    } else {
        imageData = UIImageJPEGRepresentation(image, compressionQuality);
    }
    
    [uploader addFile:[[QiniuFile alloc] initWithFileData:imageData withKey:name]];
}


@end
