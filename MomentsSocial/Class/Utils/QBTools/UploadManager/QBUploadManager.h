//
//  QBUploadManager.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBUploadManager : NSObject

+ (void)registerWithSecretKey:(NSString *)secretKey accessKey:(NSString *)accessKey scope:(NSString *)scope;

//+ (BOOL)uploadImage:(UIImage *)image
//           withName:(NSString *)name
//  completionHandler:(QBCompletionHandler)handler;
//
//+ (BOOL)uploadVoiceWithPath:(NSString *)voicePath
//                  voiceName:(NSString *)voiceName
//          completionHandler:(QBCompletionHandler)handler;

+ (BOOL)uploadWithFile:(id)object
              fileName:(NSString *)fileName
     completionHandler:(QBCompletionHandler)handler;

@end
