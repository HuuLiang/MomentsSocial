//
//  UIDevice+Model.m
//  FunTuYing
//
//  Created by Sean Yue on 2017/6/23.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "UIDevice+Model.h"
#import <sys/sysctl.h>

@implementation UIDevice (Model)

- (NSString *)fullModelName {
    size_t size;
    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *name = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return name;
}

@end
