//
//  QBPaymentConfiguration.h
//  Pods
//
//  Created by Sean Yue on 2017/6/9.
//
//

#import <Foundation/Foundation.h>
#import "QBPaymentConfigurationDetail.h"

@interface QBPaymentConfiguration : NSObject

@property (nonatomic,retain) QBPaymentConfigurationDetail *alipay;
@property (nonatomic,retain) QBPaymentConfigurationDetail *weixin;

@end
