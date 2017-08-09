//
//  MSContactView.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/9.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSAutoReplyMsg;

@interface MSContactView : UIView

+ (void)showWithReplyMsgInfo:(MSAutoReplyMsg *)replyMsg;

@end
