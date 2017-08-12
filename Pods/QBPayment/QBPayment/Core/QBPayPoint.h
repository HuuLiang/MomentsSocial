//
//  QBPayPoint.h
//  Pods
//
//  Created by Sean Yue on 2017/7/11.
//
//

#import <Foundation/Foundation.h>

@interface QBPayPoint : NSObject

@property (nonatomic) NSNumber *id;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *payPointType;
@property (nonatomic) NSNumber *fee;
@property (nonatomic) NSString *pointRecommend;
@property (nonatomic) NSString *descInfo;
@property (nonatomic) NSNumber *validMonths;
@property (nonatomic) NSNumber *validResources;

@end

typedef NSDictionary<NSString *, NSArray<QBPayPoint *> *> QBPayPoints;
