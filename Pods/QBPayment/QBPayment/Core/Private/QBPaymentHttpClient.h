//
//  QBPaymentHttpClient.h
//  Pods
//
//  Created by Sean Yue on 2017/6/2.
//
//

#import <Foundation/Foundation.h>

typedef void (^QBPaymentHttpCompletionHandler)(id obj, NSError *error);

@interface QBPaymentHttpClient : NSObject

+ (instancetype)sharedClient;
+ (instancetype)plainRequestClient;
+ (instancetype)JSONRequestClient;
+ (instancetype)XMLRequestClient;

- (void)GET:(NSString *)url withParams:(id)params completionHandler:(QBPaymentHttpCompletionHandler)completionHandler;
- (void)POST:(NSString *)url withParams:(id)params completionHandler:(QBPaymentHttpCompletionHandler)completionHandler;
- (void)POST:(NSString *)url withXMLText:(NSString *)xmlText completionHandler:(QBPaymentHttpCompletionHandler)completionHandler;

@end

// Error Domain
extern NSString *const kQBPaymentHttpClientErrorDomain;

// Invalid argument error code
extern const NSInteger kQBPaymentHttpClientInvalidArgument;
