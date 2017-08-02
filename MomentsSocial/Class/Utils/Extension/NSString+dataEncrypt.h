//
//  NSString+dataEncrypt.h
//  ShareAdvertApp
//
//  Created by Liang on 2017/7/11.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (dataEncrypt)

- (NSString *)dataEncryptedWithPassword:(NSString *)password;

- (NSString *)dataDecryptedWithPassword:(NSString *)password;

@end
