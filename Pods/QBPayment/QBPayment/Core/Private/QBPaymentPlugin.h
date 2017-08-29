//
//  QBPaymentPlugin.h
//  Pods
//
//  Created by Sean Yue on 2017/5/9.
//
//

#import <Foundation/Foundation.h>
#import "QBPaymentDefines.h"
#import "QBPaymentInfo.h"


@interface QBPaymentPlugin : NSObject

@property (nonatomic) QBPluginType pluginType;
@property (nonatomic) NSString *pluginName;
@property (nonatomic,retain) NSDictionary *paymentConfiguration;
@property (nonatomic) NSString *urlScheme;

@property (nonatomic,retain) QBPaymentInfo *paymentInfo;
@property (nonatomic,copy) QBPaymentCompletionHandler paymentCompletionHandler;
@property (nonatomic,retain) UIViewController *payingViewController;

- (UIViewController *)viewControllerForPresentingPayment;
- (NSString *)deviceName;
- (NSString *)IPAddress;

+ (void)commitPayment:(QBPaymentInfo *)paymentInfo withResult:(QBPayResult)result;
- (void)queryPaymentResultForPaymentInfo:(QBPaymentInfo *)paymentInfo withRetryTimes:(NSUInteger)retryTimes completionHandler:(QBPaymentCompletionHandler)completionHandler;
- (void)endPaymentWithPayResult:(QBPayResult)payResult;

@end

@interface QBPaymentPlugin (SubclassingHooks)

- (void)pluginDidLoad;
- (void)pluginDidSetPaymentConfiguration:(NSDictionary *)paymentConfiguration;

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler;

- (void)handleOpenURL:(NSURL *)url;
- (void)applicationWillEnterForeground:(UIApplication *)application;

- (BOOL)shouldRequirePhotoLibraryAuthorization;

@end

@interface QBPaymentPlugin (Loading)

- (void)beginLoading;
- (void)endLoading;

@end
