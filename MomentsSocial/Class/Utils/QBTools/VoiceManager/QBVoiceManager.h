//
//  QBVoiceManager.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/9.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBVoiceManager : NSObject

+ (instancetype)manager;

- (void)playFaceTimeVoice;

- (void)endFaceTimeVoice;

- (void)playSendVoice;

- (void)playReceiveVoice;


@end
