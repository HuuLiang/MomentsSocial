//
//  QBUploadManager.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "QBUploadManager.h"
#import <AFNetworking.h>
#import "QiniuToken.h"
#import "QiniuUploader.h"

@interface QBUploadManager ()
@property (nonatomic) NSString *accessToken;
@end

@implementation QBUploadManager

+ (void)registerWithSecretKey:(NSString *)secretKey accessKey:(NSString *)accessKey scope:(NSString *)scope {
    [QiniuToken registerWithScope:scope SecretKey:secretKey Accesskey:accessKey TimeToLive:3600];
}

+ (NSString *)fileUrlWithName:(NSString *)name {
    NSString *baseUrl = @"http://mfw.jtd51.com";
    if (![baseUrl hasSuffix:@"/"]) {
        baseUrl = [baseUrl stringByAppendingString:@"/"];
    }
    
    return [baseUrl stringByAppendingString:name];
}

+ (BOOL)uploadWithFile:(id)object
              fileName:(NSString *)fileName
     completionHandler:(QBCompletionHandler)handler
{
    QiniuUploader *uploader = [[QiniuUploader alloc] init];
    
    uploader.uploadOneFileSucceeded = ^(NSInteger index, NSString * _Nonnull key, NSDictionary * _Nonnull info) {
        if ([object isKindOfClass:[UIImage class]]) {
            QBSafelyCallBlock(handler,YES,[self fileUrlWithName:key]);
        }
    };
    
    uploader.uploadOneFileFailed = ^(NSInteger index, NSError * _Nullable error) {
        QBSafelyCallBlock(handler,NO,error);
    };
    
    uploader.uploadOneFileProgress = ^(NSInteger index, NSProgress * _Nonnull process) {
        QBLog(@"%@",process);
    };
    [self uploader:uploader addObject:object withName:fileName];
    return [uploader startUploadWithAccessToken:[[QiniuToken sharedQiniuToken] uploadToken]];
}

+ (void)uploader:(QiniuUploader *)uploader addObject:(id)object withName:(NSString *)name {
    NSData *fileData;
    NSString *fileType;
    if ([object isKindOfClass:[UIImage class]]) {
        fileType = @"image/jpeg";
        UIImage *image = (UIImage *)object;
        const CGFloat widthMetrics = 736;
        const CGFloat heightMetrics = 414;
        const CGFloat compressionQuality = MIN(1, MAX(widthMetrics/image.size.width, heightMetrics/image.size.height));
        
        if ([name hasSuffix:@".png"]) {
            fileData = UIImagePNGRepresentation(image);
        } else {
            fileData = UIImageJPEGRepresentation(image, compressionQuality);
        }
    }
//    else if (object isKindOfClass:[])
    
    QiniuFile *file = [[QiniuFile alloc] initWithFileData:fileData withKey:name];
    file.mimeType = fileType;
    
    [uploader addFile:file];
}

@end
