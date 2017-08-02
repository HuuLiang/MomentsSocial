//
//  QBDataManager.m
//  ShareAdvertApp
//
//  Created by Liang on 2017/7/11.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "QBDataManager.h"
#import "AFNetworking.h"
#import "QBDataResponse.h"

static NSString *const kEncryptionPasssword = @"gqi*&^R8*TfB2";

NSString *const kSAShareErrorDomain           = @"com.sharead.errordomain";
NSString *const kSAShareAdErrorMessageKeyName = @"com.sharead.errordomain.errormessage";
NSString *const kSAShareLogicErrorCodeKeyName = @"com.sharead.errordomain.logicerrorcode";

@implementation QBDataConfiguration
+ (instancetype)configuration {
    static QBDataConfiguration *_configuration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _configuration = [[QBDataConfiguration alloc] init];
    });
    return _configuration;
}
@end


@interface QBDataManager ()
@property (nonatomic,readonly) NSURL *baseUrl;
@property (nonatomic,strong) AFHTTPSessionManager *sessionManager;
@end

@implementation QBDataManager

+ (instancetype)manager {
    static QBDataManager *_dataManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dataManager = [[self alloc] initWithBaseUrl:[NSURL URLWithString:[QBDataConfiguration configuration].baseUrl]];
    });
    return _dataManager;
}

- (instancetype)initWithBaseUrl:(NSURL *)baseUrl {
    self = [self init];
    if (self) {
        _baseUrl = baseUrl;
    }
    return self;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager) {
        return _sessionManager;
    }
    
    _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:self.baseUrl];
    _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain",nil];
    return _sessionManager;
}

- (void)requestUrl:(NSString *)urlPath
        withParams:(id)params
             class:(Class)modelClass
           handler:(void(^)(id obj , NSError *error))handler {
    [self.sessionManager POST:urlPath parameters:[self encryptWithParams:params] progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        QBLog(@"HTTP URL:%@ \nResponse: %@", urlPath, responseObject);
        [self onResponseWithObject:[self decryptedWithObject:responseObject] error:nil modelClass:modelClass completionHandler:^(id obj, NSError *error) {
            handler(obj,error);
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        QBLog(@"HTTP URL:%@ \nNetwork Error: %@", urlPath, error.localizedDescription);
        [self onResponseWithObject:nil error:error modelClass:modelClass completionHandler:^(id obj, NSError *error) {
            handler(obj,error);
        }];
    }];

}

- (void)onResponseWithObject:(id)object
                       error:(NSError *)error
                  modelClass:(Class)modelClass
           completionHandler:(void(^)(id obj , NSError *error))handler {
    if (!object) {
        error = [self errorFromURLError:error];
        handler(nil,error);
    } else {
        QBDataResponse *instance = [modelClass objectFromDictionary:object];
        handler(instance,nil);
    }
}

- (NSError *)errorFromURLError:(NSError *)error {
    
    NSDictionary *errorMessages = @{@(NSURLErrorBadURL):@"地址错误",
                                    @(NSURLErrorTimedOut):@"请求超时",
                                    @(NSURLErrorUnsupportedURL):@"不支持的网络地址",
                                    @(NSURLErrorCannotFindHost):@"找不到目标服务器",
                                    @(NSURLErrorCannotConnectToHost):@"无法连接到服务器",
                                    @(NSURLErrorDataLengthExceedsMaximum):@"请求数据长度超出限制",
                                    @(NSURLErrorNetworkConnectionLost):@"网络连接断开",
                                    @(NSURLErrorDNSLookupFailed):@"DNS查找失败",
                                    @(NSURLErrorHTTPTooManyRedirects):@"HTTP重定向太多",
                                    @(NSURLErrorResourceUnavailable):@"网络资源无效",
                                    @(NSURLErrorNotConnectedToInternet):@"设备未连接到网络",
                                    @(NSURLErrorRedirectToNonExistentLocation):@"重定向到不存在的地址",
                                    @(NSURLErrorBadServerResponse):@"服务器响应错误",
                                    @(NSURLErrorUserCancelledAuthentication):@"网络授权取消",
                                    @(NSURLErrorUserAuthenticationRequired):@"需要用户授权"};
    
    
    NSString *errorMessage = errorMessages[@(error.code)];
    errorMessage = errorMessage ? [NSString stringWithFormat:@"网络请求错误：%@", errorMessage] : @"网络请求错误";
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:errorMessage forKey:kSAShareAdErrorMessageKeyName];
    if (error.code != NSIntegerMax) {
        [userInfo setObject:@(error.code) forKey:kSAShareAdErrorMessageKeyName];
    }
    return [NSError errorWithDomain:kSAShareErrorDomain code:error.code userInfo:userInfo.count > 0 ? userInfo : nil];
}


- (NSDictionary *)encryptWithParams:(id)params {
    
    if ([self.delegate respondsToSelector:@selector(encryptedWithParams:)]) {
        return [self.delegate encryptedWithParams:params];
    }
    
    if (!params) {
        return nil;
    }
    
    NSMutableArray <NSString *> *values = [[NSMutableArray alloc] init];
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSString class]]) {
            NSString *str = [NSString stringWithFormat:@"%@",obj];
            [values addObject:str];
        } else {
            [values addObject:obj];
        }
    }];
    
    [values sortUsingComparator:^NSComparisonResult(NSString * _Nonnull obj1, NSString * _Nonnull obj2) {
        NSRange range = NSMakeRange(0, obj1.length);
        return [obj1 compare:obj2 options:
                NSWidthInsensitiveSearch range:range];
    }];
    
    NSMutableString *valueStr = [[NSMutableString alloc] init];
    [values enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [valueStr appendString:obj];
    }];
    
    NSString *md5Str = valueStr.md5.uppercaseString;
    
    NSMutableDictionary *newParams = [[NSMutableDictionary alloc] init];
    [newParams setObject:md5Str forKey:@"sign"];
    [newParams addEntriesFromDictionary:params];
    
    NSMutableArray *newParamsArr = [[NSMutableArray alloc] init];
    [newParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *newStr = [NSString stringWithFormat:@"%@=%@",key,obj];
        [newParamsArr addObject:newStr];
    }];
    
    NSString *originStr = [newParamsArr componentsJoinedByString:@"&"];
    
    NSString *encryStr = [originStr dataEncryptedWithPassword:[kEncryptionPasssword.md5 substringToIndex:16]];
    
    return @{@"data":encryStr};
}

- (id)decryptedWithObject:(id)responseObject {
    if ([self.delegate respondsToSelector:@selector(decryptedWithResponseObject:)]) {
        return [self.delegate decryptedWithResponseObject:responseObject];
    }
    
    NSString *sss = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    NSString *str = [sss dataDecryptedWithPassword:[kEncryptionPasssword.md5 substringToIndex:16]];
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    
    QBLog(@"resonseJSON:%@",responseJSON);
    return responseJSON;
}


@end
