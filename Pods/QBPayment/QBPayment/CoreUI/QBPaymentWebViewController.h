//
//  QBPaymentWebViewController.h
//  Pods
//
//  Created by Sean Yue on 2016/10/21.
//
//

#import <UIKit/UIKit.h>

@interface QBPaymentWebViewController : UIViewController

@property (nonatomic,copy) void (^closeAction)(void);
@property (nonatomic,copy) void (^capturedAlipayRequest)(NSURL *url, id obj);
@property (nonatomic,copy) void (^capturedWeChatRequest)(NSURL *url, id obj);
@property (nonatomic,copy) void (^customUrlRequest)(NSMutableURLRequest *request);
@property (nonatomic,copy) void (^capturedPaymentTimeOutAction)(void);

@property (nonatomic) BOOL shouldBeginLoadingWhenViewDidAppear;
@property (nonatomic) BOOL forceToUseWebView;

- (instancetype)initWithHTMLString:(NSString *)htmlString;
- (instancetype)initWithURL:(NSURL *)url;

@end
