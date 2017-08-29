//
//  DmePayAPI.h
//  01-NSURLSession发送GET请求和POST请求
//
//  Created by Admin on 17/7/14.
//  Copyright © 2017年 文顶顶. All rights reserved.
//

#import <Foundation/Foundation.h>

//支付通道标示
typedef NS_ENUM(NSInteger, DmePayType)
{
    kPTWeixinPay = 23,
    kPTAlipay = 22,
};


//@protocol DmePayAPIDelegate <NSObject>
//
//@optional
//
//-(void) onPaid:(int) status description:(NSString*) info;
//
//@end


typedef void(^PaidBlock)(int status,NSString* description);


@interface DmePayAPI : NSObject






+ (void) init:(NSString*) parternerid partnername:(NSString*) name partnertoken:(NSString*) token ;

//+ (void) startPay:(NSString*) name goodsid:(NSString*) goodsId goodsfee:(NSString*) fee  goodscomment:(NSString*) comment
//          paytype:(DmePayType) payType callback:(id) delegate;

+ (void) startPay:(NSString*) name goodsid:(NSString*) goodsId goodsfee:(NSString*) fee  goodscomment:(NSString*) comment
          paytype:(DmePayType) payType callback:(PaidBlock)paidBlock;

+ (void)handleOpenUrl:(NSURL *)url;

@end
