//
//  QBPaymentPluginManager.h
//  Pods
//
//  Created by Sean Yue on 2017/5/9.
//
//

#import <Foundation/Foundation.h>
#import "QBPaymentPlugin.h"
#import "QBPaymentConfiguration.h"

@interface QBPaymentPluginManager : NSObject

@property (nonatomic,retain) QBPaymentConfiguration *paymentConfiguration;
@property (nonatomic) NSString *urlScheme;

+ (instancetype)sharedManager;

- (void)loadAllPlugins;

// Plugin Queries
- (NSArray<QBPaymentPlugin *> *)allPlugins;
- (QBPaymentPlugin *)pluginWithType:(QBPluginType)pluginType;
- (BOOL)pluginIsEnabled:(QBPluginType)pluginType;

@end
