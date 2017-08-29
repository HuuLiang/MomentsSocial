//
//  NSBundle+BundleInfo.m
//  FunTuYing
//
//  Created by Sean Yue on 2017/8/18.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "NSBundle+BundleInfo.h"

@implementation NSBundle (BundleInfo)

- (NSString *)bundleVersion {
    return self.infoDictionary[@"CFBundleShortVersionString"];
}

- (NSString *)bundleName {
    return self.infoDictionary[@"CFBundleDisplayName"];
}
@end
