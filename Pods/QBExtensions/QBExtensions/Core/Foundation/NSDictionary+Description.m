//
//  NSDictionary+Description.m
//  Pods
//
//  Created by Sean Yue on 2017/8/21.
//
//

#import "NSDictionary+Description.h"

@implementation NSDictionary (Description)

- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *string = [NSMutableString string];
    
    // 开头有个{
    [string appendString:@"{\n"];
    
    // 遍历所有的键值对
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [string appendFormat:@"\t%@%@%@", [key isKindOfClass:[NSString class]]?@"\"":@"", key, [key isKindOfClass:[NSString class]]?@"\"":@""];
        [string appendString:@" : "];
        
        [string appendFormat:@"%@%@%@,\n", [obj isKindOfClass:[NSString class]]?@"\"":@"", obj, [obj isKindOfClass:[NSString class]]?@"\"":@""];
    }];
    
    // 结尾有个}
    [string appendString:@"}"];
    
    // 查找最后一个逗号
    NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
    if (range.location != NSNotFound)
        [string deleteCharactersInRange:range];
    
    return string;
}
@end
