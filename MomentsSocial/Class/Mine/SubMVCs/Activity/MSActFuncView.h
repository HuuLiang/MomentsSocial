//
//  MSActFuncView.h
//  MomentsSocial
//
//  Created by Liang on 2017/9/26.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MSActFuncType) {
    MSActFuncViewNone,
    MSActFuncTypeJoin,
    MSActFuncTypeInput,
    MSActFuncTypeBinding
};

@interface MSActFuncView : UIView

@property (nonatomic) MSActFuncType funcType;

@property (nonatomic) MSAction joinAction;

- (void)resignResponder;
@end
