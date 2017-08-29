//
//  NSBundle+BundleInfo.h
//  FunTuYing
//
//  Created by Sean Yue on 2017/8/18.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (BundleInfo)

@property (nonatomic,readonly) NSString *bundleVersion;
@property (nonatomic,readonly) NSString *bundleName;

@end
