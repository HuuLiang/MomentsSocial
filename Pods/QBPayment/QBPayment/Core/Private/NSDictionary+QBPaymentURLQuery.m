//
//  NSDictionary+QBPaymentURLQuery.m
//  QBPayment
//
//  Created by Sean Yue on 2017/10/23.
//

#import "NSDictionary+QBPaymentURLQuery.h"

@implementation NSDictionary (QBPaymentURLQuery)

- (NSString *)QBP_URLQueryString {
    NSMutableString *queryString = [NSMutableString string];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (queryString.length > 0) {
            [queryString appendString:@"&"];
        }

        [queryString appendFormat:@"%@=%@", key, obj];
    }];

    return queryString.length > 0 ? queryString : nil;
}

@end
