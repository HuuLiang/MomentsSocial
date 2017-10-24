//
//  QBPaymentWebViewController.m
//  Pods
//
//  Created by Sean Yue on 2016/10/21.
//
//

#import "QBPaymentWebViewController.h"
#import "MBProgressHUD.h"
@import WebKit;

@interface QBPaymentWebViewController () <UIAlertViewDelegate,WKNavigationDelegate,UIWebViewDelegate>
{
//    UIWebView *_webView;
}
//@property (nonatomic,retain) UIView *webView;
@property (nonatomic,retain) NSString *htmlString;
@property (nonatomic,retain) NSURL *url;
@end

@implementation QBPaymentWebViewController

- (instancetype)initWithHTMLString:(NSString *)htmlString {
    self = [self init];
    if (self) {
        _htmlString = htmlString;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [self init];
    if (self) {
        _url = url;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldBeginLoadingWhenViewDidAppear = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"支付跳转中。。。";
    
    BOOL useWKWebView = NSClassFromString(@"WKWebView") != nil;
    if (self.forceToUseWebView) {
        useWKWebView = NO;
    }
    UIView *webView;
    
    if (useWKWebView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        wkWebView.navigationDelegate = self;
        webView = wkWebView;
        
    } else {
        UIWebView *uiWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        uiWebView.scalesPageToFit = YES;
        uiWebView.delegate = self;
        webView = uiWebView;
    }
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:webView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(onClose)];
    
    if (self.htmlString) {
        if ([webView respondsToSelector:@selector(loadHTMLString:baseURL:)]) {
            [webView performSelector:@selector(loadHTMLString:baseURL:) withObject:self.htmlString withObject:nil];
        }
    } else {
        if ([webView respondsToSelector:@selector(loadRequest:)]) {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
            if (self.customUrlRequest) {
                self.customUrlRequest(request);
            }
            [webView performSelector:@selector(loadRequest:) withObject:request];
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldBeginLoadingWhenViewDidAppear) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    [self performSelector:@selector(capturedTimeOut) withObject:nil afterDelay:10];
}

- (void)capturedTimeOut {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.capturedPaymentTimeOutAction) {
            self.capturedPaymentTimeOutAction();
        }
    }];
}

- (void)onCapturedPaymentRequest {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(capturedTimeOut) object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.shouldBeginLoadingWhenViewDidAppear) {
        [[MBProgressHUD HUDForView:self.view] hide:YES];
    }
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%@ dealloc", [self class]);
#endif
}

- (void)onClose {
    if (self.closeAction) {
        self.closeAction();
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([navigationAction.request.URL.absoluteString hasPrefix:@"alipay"]) {
        [self onCapturedPaymentRequest];
        if (self.capturedAlipayRequest) {
            self.capturedAlipayRequest(navigationAction.request.URL, self);
            decisionHandler(WKNavigationActionPolicyCancel);
            return ;
        }
    } else if ([navigationAction.request.URL.scheme isEqualToString:@"weixin"]) {
        [self onCapturedPaymentRequest];
        if (self.capturedWeChatRequest) {
            self.capturedWeChatRequest(navigationAction.request.URL, self);
            decisionHandler(WKNavigationActionPolicyCancel);
            return ;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.absoluteString hasPrefix:@"alipay"]) {
        [self onCapturedPaymentRequest];
        if (self.capturedAlipayRequest) {
            self.capturedAlipayRequest(request.URL, self);
            return NO;
        }
    } else if ([request.URL.scheme isEqualToString:@"weixin"]) {
        [self onCapturedPaymentRequest];
        if (self.capturedWeChatRequest) {
            self.capturedWeChatRequest(request.URL, self);
            return NO;
        }
    }
    return YES;
}
@end
