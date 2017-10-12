//
//  QBPaymentPluginManager.m
//  Pods
//
//  Created by Sean Yue on 2017/5/9.
//
//

#import "QBPaymentPluginManager.h"
#import "NSString+crypt.h"

static NSString *const kQBPaymentConfigurationUserDefaultsKey = @"com.qbpayment.userdefaults.payconfig";
static NSString *const kQBPaymentConfigurationCryptionPassword = @"eiafjsiajo339045$^%&#%@%";

@interface QBPaymentPluginManager ()
@property (nonatomic,retain) NSMutableArray<QBPaymentPlugin *> *plugins;
@property (nonatomic,retain,readonly) NSArray<NSString *> *pluginClassNames;
//@property (nonatomic,retain) NSDictionary *pluginConfiguration;
@end

@implementation QBPaymentPluginManager

QBDefineLazyPropertyInitialization(NSMutableArray, plugins)
QBSynthesizeSingletonMethod(sharedManager)

- (void)loadAllPlugins {
    __block BOOL shouldRequirePhotoLibraryAuthorization = NO;
    [self.pluginClassNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Class class = NSClassFromString(obj);
        if ([class isSubclassOfClass:[QBPaymentPlugin class]]) {
            QBPaymentPlugin *plugin = [[class alloc] init];
            [plugin pluginDidLoad];
            [self.plugins addObject:plugin];
            
            if ([plugin shouldRequirePhotoLibraryAuthorization]) {
                shouldRequirePhotoLibraryAuthorization = YES;
            }
            QBLog(@"✅✅✅Loaded plugin with name: %@ and ID: %ld", plugin.pluginName, (unsigned long)plugin.pluginType);
        }
    }];
    
#ifdef DEBUG
    if (shouldRequirePhotoLibraryAuthorization) {
        NSString *photoAuth = [NSBundle mainBundle].infoDictionary[@"NSPhotoLibraryUsageDescription"];
        NSAssert(photoAuth, @"⚠️You have integrated LSPay but no NSPhotoLibraryUsageDescription key-value in info.plist, which may lead to a crash if user selects QR code payment and saves the QR image to local photo albums!⚠️\n⚠️你已经集成了雷胜支付，但是并没有在info.plist中添加允许访问图片库的描述，当用户选择扫码支付并且保存二维码到本地图片库的时候，将会导致程序崩溃！⚠️");
    }
    
    NSArray<NSString *> *essentialSchemes = @[@"alipay",@"wechat",@"alipayqr",@"weixin",@"mqq",@"alipays"];
    NSArray<NSString *> *querySchemes = [NSBundle mainBundle].infoDictionary[@"LSApplicationQueriesSchemes"];
    NSMutableArray *excludeSchemes = [NSMutableArray array];
    [essentialSchemes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![querySchemes containsObject:obj]) {
            [excludeSchemes addObject:obj];
        }
    }];
    
    if (excludeSchemes.count > 0) {
        QBLog(@"⚠️The schemes: %@ are not found in your info.plist, and the payment may fail to invoke the corresponding apps!⚠️", excludeSchemes);
        QBLog(@"⚠️%@的scheme未包含在info.plist中，调起相应的app支付有可能会失败！⚠️", excludeSchemes);
    }
#endif
//    NSString *configString = [[NSUserDefaults standardUserDefaults] objectForKey:kQBPaymentConfigurationUserDefaultsKey];
//    if (configString) {
//        configString = [configString decryptedStringWithPassword:kQBPaymentConfigurationCryptionPassword];
//        NSDictionary *configuration = [NSJSONSerialization JSONObjectWithData:[configString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
//        [self parsePluginConfiguration:configuration];
//    }
}

//- (void)setPluginConfiguration:(NSDictionary *)configuration {
//    if (![configuration isKindOfClass:[NSDictionary class]]) {
//        return ;
//    }
//    
//    NSNumber *code = configuration[@"code"];
//    if (!code || code.unsignedIntegerValue != 100) {
//        return ;
//    }
//    
//    _pluginConfiguration = configuration;
//    
//    [self parsePluginConfiguration:configuration];
//}
//
//- (void)parsePluginConfiguration:(NSDictionary *)configuration {
//    
//}

- (void)setPaymentConfiguration:(QBPaymentConfiguration *)paymentConfiguration {
    _paymentConfiguration = paymentConfiguration;
    
    QBPaymentPlugin *weixnPlugin = [self pluginWithType:paymentConfiguration.weixin.type.unsignedIntegerValue];
    weixnPlugin.paymentConfiguration = paymentConfiguration.weixin.config;
    weixnPlugin.urlScheme = self.urlScheme;
    
    QBPaymentPlugin *alipayPlugin = [self pluginWithType:paymentConfiguration.alipay.type.unsignedIntegerValue];
    alipayPlugin.paymentConfiguration = paymentConfiguration.alipay.config;
    alipayPlugin.urlScheme = self.urlScheme;
}

- (void)setUrlScheme:(NSString *)urlScheme {
    _urlScheme = urlScheme;
    
    QBPaymentPlugin *weixnPlugin = [self pluginWithType:self.paymentConfiguration.weixin.type.unsignedIntegerValue];
    weixnPlugin.urlScheme = urlScheme;
    
    QBPaymentPlugin *alipayPlugin = [self pluginWithType:self.paymentConfiguration.alipay.type.unsignedIntegerValue];
    alipayPlugin.urlScheme = urlScheme;
}

- (NSArray<QBPaymentPlugin *> *)allPlugins {
    return self.plugins;
}

- (QBPaymentPlugin *)pluginWithType:(QBPluginType)pluginType {
    __block QBPaymentPlugin *plugin;
    [self.plugins enumerateObjectsUsingBlock:^(QBPaymentPlugin * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.pluginType == pluginType) {
            plugin = obj;
            *stop = YES;
        }
    }];
    return plugin;
}

- (BOOL)pluginIsEnabled:(QBPluginType)pluginType {
    return [self pluginWithType:pluginType] != nil;
}

- (NSArray<NSString *> *)pluginClassNames {
    return @[@"WeChatPaymentPlugin",
             @"AlipayPlugin",
             @"IappPaymentPlugin",
             @"VIAPaymentPlugin",
             @"WFTPaymentPlugin",
             @"YiPaymentPlugin",
             @"WJPaymentPlugin",
             @"JiePaymentPlugin",
             @"MingPaymentPlugin",
             @"HaiJiaPaymentPlugin",
             @"DmePaymentPlugin",
             @"HuiPaymentPlugin",
             @"DXTXPaymentPlugin",
             @"ZYPaymentPlugin",
             @"XinPaymentPlugin",
             @"BNPaymentPlugin",
             @"ZGBNPaymentPlugin",
             @"WeiPaymentPlugin",
             @"XXBPaymentPlugin",
             @"BBPaymentPlugin",
             @"LePaymentPlugin",
             @"LBPaymentPlugin",
             @"RocketPaymentPlugin"];
}
@end
