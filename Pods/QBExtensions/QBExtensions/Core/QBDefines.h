//
//  QBMacros.h
//  Pods
//
//  Created by Sean Yue on 16/6/17.
//
//

#ifndef QBMacros_h
#define QBMacros_h

#import <RACEXTScope.h>
#import <NSDate+Utilities.h>
#import <NSDictionary+Description.h>
#import <NSArray+Description.h>

#ifdef  DEBUG
#define QBLog(fmt,...) {printf("%s\n", [NSString stringWithFormat:@"%@ - %@", [NSDate date].standardString,  [NSString stringWithFormat:fmt, ##__VA_ARGS__]].UTF8String);}
#else
#define QBLog(...)
#endif

#define QBDefineLazyPropertyInitialization(propertyType, propertyName) \
-(propertyType *)propertyName { \
if (_##propertyName) { \
return _##propertyName; \
} \
_##propertyName = [[propertyType alloc] init]; \
return _##propertyName; \
}

#define QBSafelyCallBlock(block,...) \
if (block) block(__VA_ARGS__);

#define QBSafelyCallBlockAndRelease(block,...) \
if (block) { block(__VA_ARGS__); block = nil;};

#define QBDeclareSingletonMethod(methodName) \
+ (instancetype)methodName;

#define QBSynthesizeSingletonMethod(methodName) \
+ (instancetype)methodName { \
static id _methodName; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{\
_methodName = [[self alloc] init]; \
}); \
return _methodName; \
}

#define QBAssociatedButtonWithActionByPassOriginalSender(button, action) \
__weak typeof(self) button##WeakSelf = self; \
[button bk_addEventHandler:^(id sender) { \
__strong typeof(button##WeakSelf) button##StrongSelf = button##WeakSelf; \
QBSafelyCallBlock(button##StrongSelf.action, sender); \
} forControlEvents:UIControlEventTouchUpInside];

#define QBAssociatedButtonWithAction(button, action) \
__weak typeof(self) button##WeakSelf = self; \
[button bk_addEventHandler:^(id sender) { \
__strong typeof(button##WeakSelf) button##StrongSelf = button##WeakSelf; \
QBSafelyCallBlock(button##StrongSelf.action, button##StrongSelf); \
} forControlEvents:UIControlEventTouchUpInside];

#define QBAssociatedViewWithTapAction(view, action) \
__weak typeof(self) view##WeakSelf = self; \
[view bk_whenTapped:^{ \
__strong typeof(view##WeakSelf) view##StrongSelf = view##WeakSelf; \
QBSafelyCallBlock(view##StrongSelf.action, self); \
}];

#define kScreenHeight     [ [ UIScreen mainScreen ] bounds ].size.height
#define kScreenWidth      [ [ UIScreen mainScreen ] bounds ].size.width

#define kExExHugeFont [UIFont systemFontOfSize:MIN(50,roundf(kScreenWidth*0.15))]
#define kExExHugeBoldFont [UIFont boldSystemFontOfSize:MIN(50,roundf(kScreenWidth*0.15))]

#define kExtraHugeFont [UIFont systemFontOfSize:MIN(40,roundf(kScreenWidth*0.12))]
#define kExtraHugeBoldFont [UIFont boldSystemFontOfSize:MIN(40,roundf(kScreenWidth*0.12))]
#define kHugeFont     [UIFont systemFontOfSize:MIN(26,roundf(kScreenWidth*0.075))]
#define kHugeBoldFont [UIFont boldSystemFontOfSize:MIN(26,roundf(kScreenWidth*0.075))]
#define kExtraBigFont [UIFont systemFontOfSize:MIN(20,roundf(kScreenWidth*0.055))]
#define kExtraBigBoldFont [UIFont boldSystemFontOfSize:MIN(20,roundf(kScreenWidth*0.055))]
#define kBigFont  [UIFont systemFontOfSize:MIN(18,roundf(kScreenWidth*0.05))]
#define kBigBoldFont [UIFont boldSystemFontOfSize:MIN(18,roundf(kScreenWidth*0.05))]
#define kMediumFont [UIFont systemFontOfSize:MIN(16, roundf(kScreenWidth*0.045))]
#define kMediumBoldFont [UIFont boldSystemFontOfSize:MIN(16, roundf(kScreenWidth*0.045))]
#define kSmallFont [UIFont systemFontOfSize:MIN(14, roundf(kScreenWidth*0.04))]
#define kExtraSmallFont [UIFont systemFontOfSize:MIN(12, roundf(kScreenWidth*0.035))]
#define kExExSmallFont [UIFont systemFontOfSize:MIN(10, roundf(kScreenWidth*0.03))]
#define kTinyFont [UIFont systemFontOfSize:MIN(8, roundf(kScreenWidth*0.025))]

#define kExtraBigVerticalSpacing roundf(kScreenHeight * 0.016)
#define kBigVerticalSpacing roundf(kScreenHeight * 0.012)
#define kMediumVerticalSpacing roundf(kScreenHeight * 0.008)
#define kSmallVerticalSpacing roundf(kScreenHeight * 0.004)

#define kExtraBigHorizontalSpacing  roundf(kScreenWidth * 0.04)
#define kBigHorizontalSpacing       roundf(kScreenWidth * 0.024)
#define kMediumHorizontalSpacing    roundf(kScreenWidth * 0.016)
#define kSmallHorizontalSpacing     roundf(kScreenWidth * 0.008)

#define kLeftRightContentMarginSpacing kExtraBigHorizontalSpacing
#define kTopBottomContentMarginSpacing kExtraBigVerticalSpacing

typedef void (^QBAction)(id obj);
typedef void (^QBCompletionHandler)(BOOL success, id obj);

#endif /* QBMacros_h */
