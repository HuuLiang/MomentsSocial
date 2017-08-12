//
//  QBPaymentHttpClient.m
//  Pods
//
//  Created by Sean Yue on 2017/6/2.
//
//

#import "QBPaymentHttpClient.h"
#import <AFHTTPSessionManager.h>
#import "QBPaymentDefines.h"
#import <objc/runtime.h>

NSString *const kQBPaymentHttpClientErrorDomain = @"com.qbpayment.errordomain.httpclient";

const NSInteger kQBPaymentHttpClientInvalidArgument = NSIntegerMin;

static const void* kDataTaskCompletionAssociatedKey = &kDataTaskCompletionAssociatedKey;
static const NSTimeInterval kDefaultTimeOut = 10;

@interface QBPaymentHttpClient () <NSURLSessionDataDelegate>
@property (nonatomic,retain) AFHTTPSessionManager *sessionManager;
@property (nonatomic,retain) NSURLSession *xmlSession;
@end

@implementation QBPaymentHttpClient

+ (instancetype)sharedClient {
    static QBPaymentHttpClient *_sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
    });
    return _sharedClient;
}

+ (instancetype)plainRequestClient {
    static QBPaymentHttpClient *_plainRequestClient;
    static dispatch_once_t plainToken;
    dispatch_once(&plainToken, ^{
        _plainRequestClient = [[self alloc] init];
        _plainRequestClient.sessionManager.requestSerializer.timeoutInterval = kDefaultTimeOut;
        _plainRequestClient.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    return _plainRequestClient;
}

+ (instancetype)JSONRequestClient {
    static QBPaymentHttpClient *_JSONRequestClient;
    static dispatch_once_t jsonToken;
    dispatch_once(&jsonToken, ^{
        _JSONRequestClient = [[self alloc] init];
        _JSONRequestClient.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _JSONRequestClient.sessionManager.requestSerializer.timeoutInterval = kDefaultTimeOut;
        _JSONRequestClient.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    return _JSONRequestClient;
}

+ (instancetype)XMLRequestClient {
    static QBPaymentHttpClient *_XMLRequestClient;
    static dispatch_once_t xmlToken;
    dispatch_once(&xmlToken, ^{
        _XMLRequestClient = [[self alloc] init];
        
    });
    return _XMLRequestClient;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager) {
        return _sessionManager;
    }
    
    _sessionManager = [[AFHTTPSessionManager alloc] init];
    _sessionManager.requestSerializer.timeoutInterval = kDefaultTimeOut;
    return _sessionManager;
}

- (NSURLSession *)xmlSession {
    if (_xmlSession) {
        return _xmlSession;
    }
    
    _xmlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    return _xmlSession;
}

- (void)GET:(NSString *)url withParams:(id)params completionHandler:(QBPaymentHttpCompletionHandler)completionHandler {
    [self request:url withParams:params method:@"GET" completionHandler:completionHandler];
}

- (void)POST:(NSString *)url withParams:(id)params completionHandler:(QBPaymentHttpCompletionHandler)completionHandler {
    [self request:url withParams:params method:@"POST" completionHandler:completionHandler];
}

- (void)POST:(NSString *)url withXMLText:(NSString *)xmlText completionHandler:(QBPaymentHttpCompletionHandler)completionHandler {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [xmlText dataUsingEncoding:NSUTF8StringEncoding];
    request.timeoutInterval = kDefaultTimeOut;
    
    NSURLSessionDataTask *dataTask = [self.xmlSession dataTaskWithRequest:request];
    objc_setAssociatedObject(dataTask, kDataTaskCompletionAssociatedKey, completionHandler, OBJC_ASSOCIATION_COPY);
    [dataTask resume];
    
}

- (void)request:(NSString *)url withParams:(id)params method:(NSString *)method completionHandler:(QBPaymentHttpCompletionHandler)completionHandler {
    QBLog(@"QBPayment request url: %@ with params:\n%@", url, params);
    
    if ([method isEqualToString:@"GET"]) {
        [self.sessionManager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            QBSafelyCallBlock(completionHandler, responseObject, nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            QBSafelyCallBlock(completionHandler, nil, [NSError errorWithDomain:kQBPaymentHttpClientErrorDomain code:error.code userInfo:error.userInfo]);
        }];
    } else if ([method isEqualToString:@"POST"]) {

        [self.sessionManager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            QBSafelyCallBlock(completionHandler, responseObject, nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            QBSafelyCallBlock(completionHandler, nil, [NSError errorWithDomain:kQBPaymentHttpClientErrorDomain code:error.code userInfo:error.userInfo]);
        }];
    } else {
        QBSafelyCallBlock(completionHandler, nil, [NSError errorWithDomain:kQBPaymentHttpClientErrorDomain code:kQBPaymentHttpClientInvalidArgument userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"不支持的请求方法：%@", method]}]);
    }
    
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    QBPaymentHttpCompletionHandler completion = objc_getAssociatedObject(dataTask, kDataTaskCompletionAssociatedKey);
    
    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    if (statusCode != 200) {
        
        completionHandler(NSURLSessionResponseCancel);
        QBSafelyCallBlock(completion, nil , [NSError errorWithDomain:kQBPaymentHttpClientErrorDomain code:statusCode userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"错误: %@", [NSHTTPURLResponse localizedStringForStatusCode:statusCode]]}]);
        
    } else {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    QBPaymentHttpCompletionHandler completion = objc_getAssociatedObject(dataTask, kDataTaskCompletionAssociatedKey);
    QBSafelyCallBlock(completion, data, nil);
}
@end
