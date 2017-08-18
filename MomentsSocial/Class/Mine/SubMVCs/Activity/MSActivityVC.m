//
//  MSActivityVC.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/18.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSActivityVC.h"

@interface MSActivityVC ()
@property (nonatomic) UIWebView *webView;
@end

@implementation MSActivityVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] init];
    [self.view addSubview:_webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:MS_ACTIVITY_URL]];
    [_webView loadRequest:request];
    
    {
        [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
