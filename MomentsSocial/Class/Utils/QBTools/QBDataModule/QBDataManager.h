//
//  QBDataManager.h
//  ShareAdvertApp
//
//  Created by Liang on 2017/7/11.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 如果需要实现自己加解密方法 请实现以下方法 */
@protocol QBEncryptionDelegate <NSObject>

/** 加密 */
- (NSDictionary *)encryptedWithParams:(id)params;

/** 解密 */
- (id)decryptedWithResponseObject:(id)responseObject;

@end

@interface QBDataConfiguration : NSObject
+ (instancetype)configuration;
@property (nonatomic) NSString *baseUrl;
@end


@interface QBDataManager : NSObject

+ (instancetype)manager;

@property (nonatomic,weak) id <QBEncryptionDelegate> delegate;

- (void)requestUrl:(NSString *)urlPath
        withParams:(id)params
             class:(Class)modelClass
           handler:(void(^)(id obj , NSError *error))handler;

@end
