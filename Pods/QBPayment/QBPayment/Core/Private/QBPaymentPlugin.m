//
//  QBPaymentPlugin.m
//  Pods
//
//  Created by Sean Yue on 2017/5/9.
//
//

#import "QBPaymentPlugin.h"
#import "AFNetworking.h"
#import "QBPaymentNetworkingManager.h"
#import <sys/sysctl.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <MBProgressHUD.h>
#import "QBPaymentWebViewController.h"
#import <NSString+md5.h>

@interface QBPaymentPlugin ()

@end

@implementation QBPaymentPlugin

- (NSString *)pluginName {
    if (_pluginName) {
        return _pluginName;
    }
    
    _pluginName = NSStringFromClass([self class]);
    return _pluginName;
}

- (void)setPaymentConfiguration:(NSDictionary *)paymentConfiguration {
    _paymentConfiguration = paymentConfiguration;
    
    [self pluginDidSetPaymentConfiguration:paymentConfiguration];
}

- (NSUInteger)minimalPrice {
    return 100;
}

- (void)pluginDidLoad {}
- (void)pluginDidSetPaymentConfiguration:(NSDictionary *)paymentConfiguration {}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler {
    self.paymentInfo = paymentInfo;
    self.paymentCompletionHandler = completionHandler;
}

- (void)handleOpenURL:(NSURL *)url {}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (self.paymentInfo) {
        @weakify(self);
        [self beginLoading];
        [self queryPaymentResultForPaymentInfo:self.paymentInfo
                                withRetryTimes:3
                             completionHandler:^(QBPayResult payResult, QBPaymentInfo *paymentInfo)
         {
             @strongify(self);
             [self endPaymentWithPayResult:payResult];
             
         }];
    }
}

- (BOOL)shouldRequirePhotoLibraryAuthorization {
    return NO;
}

+ (void)commitPayment:(QBPaymentInfo *)paymentInfo withResult:(QBPayResult)result {
    NSDateFormatter *dateFormmater = [[NSDateFormatter alloc] init];
    [dateFormmater setDateFormat:@"yyyyMMddHHmmss"];
    
    paymentInfo.paymentResult = result;
    paymentInfo.paymentStatus = QBPayStatusNotProcessed;
    paymentInfo.paymentTime = [dateFormmater stringFromDate:[NSDate date]];
    [paymentInfo save];
    
    [[QBPaymentNetworkingManager defaultManager] request_commitPaymentInfo:paymentInfo withCompletionHandler:nil];
}

- (void)queryPaymentResultForPaymentInfo:(QBPaymentInfo *)paymentInfo
                          withRetryTimes:(NSUInteger)retryTimes
                       completionHandler:(QBPaymentCompletionHandler)completionHandler
{
    if (QBP_STRING_IS_EMPTY(paymentInfo.orderId)) {
        QBSafelyCallBlock(completionHandler, QBPayResultUnknown, paymentInfo);
        return ;
    }
    
    if (retryTimes == 0) {
        return ;
    }
    
    [[QBPaymentNetworkingManager defaultManager] request_queryOrders:paymentInfo.orderId
                                               withCompletionHandler:^(BOOL success, id obj)
    {
        if (success) {
            QBSafelyCallBlock(completionHandler, QBPayResultSuccess, paymentInfo);
        } else if (retryTimes == 1) {
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self queryPaymentResultForPaymentInfo:paymentInfo
                                        withRetryTimes:retryTimes-1
                                     completionHandler:completionHandler];
            });
        }
        
    }];
}

- (void)endPaymentWithPayResult:(QBPayResult)payResult {
    [self endLoading];
    
    QBPaymentInfo *paymentInfo = self.paymentInfo;
    if (!paymentInfo) {
        return ;
    }
    
    UIViewController *payingVC = self.payingViewController;
    
    self.paymentInfo = nil;
    self.payingViewController = nil;
    
    if (paymentInfo) {
        [[self class] commitPayment:paymentInfo withResult:payResult];
    }
    
    if (payingVC) {
        [payingVC dismissViewControllerAnimated:YES completion:^{
            
            QBSafelyCallBlock(self.paymentCompletionHandler, payResult, paymentInfo);
            
            self.paymentCompletionHandler = nil;
        }];
    } else {
        QBSafelyCallBlock(self.paymentCompletionHandler, payResult, paymentInfo);
        
        self.paymentCompletionHandler = nil;
    }
}

- (UIViewController *)viewControllerForPresentingPayment {
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (viewController.presentedViewController) {
        viewController = viewController.presentedViewController;
    }
    return viewController;
}

- (NSString *)deviceName {
    size_t size;
    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *name = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return name;
}

- (NSString *)IPAddress {
    NSString *address = @"127.0.0.1";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

- (void)beginLoading {
    if (![MBProgressHUD HUDForView:[UIApplication sharedApplication].delegate.window]) {
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    }
}

- (void)endLoading {
    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
}
    
- (void)openPayUrl:(NSURL *)url forPaymentInfo:(QBPaymentInfo *)paymentInfo withCompletionHandler:(QBPaymentCompletionHandler)completionHandler {
    @weakify(self);
    void (^capturedRequest)(NSURL *url, id obj) = ^(NSURL *url, id obj) {
        @strongify(self);
        
        self.paymentInfo = paymentInfo;
        self.paymentCompletionHandler = completionHandler;
        self.payingViewController = obj;
        
        [[UIApplication sharedApplication] openURL:url];
    };
    
    QBPaymentWebViewController *webVC = [[QBPaymentWebViewController alloc] initWithURL:url];
    webVC.capturedWeChatRequest = capturedRequest;
    webVC.capturedAlipayRequest = capturedRequest;
    [[self viewControllerForPresentingPayment] presentViewController:webVC animated:YES completion:nil];
}
    
- (NSString *)uniqueString {
    NSString *unique = [NSUUID UUID].UUIDString.md5;
    if (QBP_STRING_IS_EMPTY(unique)) {
        unique = @([[NSDate date] timeIntervalSince1970]).stringValue.md5;
    }
    return unique;
}
@end
