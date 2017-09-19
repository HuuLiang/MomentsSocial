//
//  MSMessageViewController.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "XHMessageTableViewController.h"
#import <AVFoundation/AVFoundation.h>

@class MSMessageModel;

@interface MSMessageViewController : XHMessageTableViewController

@property (nonatomic,readonly) NSString *userId;
@property (nonatomic,readonly) NSString *nickName;
@property (nonatomic,readonly) NSString *portraitUrl;

@property (nonatomic, strong) XHMessageTableViewCell *currentSelectedCell;
@property (nonatomic) AVPlayer *player;

+ (instancetype)showMessageWithUserId:(NSInteger)userId
                             nickName:(NSString *)nickName
                          portraitUrl:(NSString *)portraitUrl
                     inViewController:(UIViewController *)viewController;

+ (instancetype)presentMessageWithUserId:(NSInteger)userId
                                nickName:(NSString *)nickName
                             portraitUrl:(NSString *)portraitUrl
                        inViewController:(UIViewController *)viewController;

- (void)addTextMessage:(NSString *)message
            withSender:(NSString *)sender
              receiver:(NSString *)receiver
              dateTime:(NSInteger)dateTime;

- (void)addVoiceMessage:(NSString *)voicePath
          voiceDuration:(NSString *)voiceDuration
             withSender:(NSString *)sender
               receiver:(NSString *)receiver
               dateTime:(NSInteger)dateTime;

- (void)addPhotoMessage:(NSString *)imgUrl
             withSender:(NSString *)sender
               receiver:(NSString *)receiver
               dateTime:(NSInteger)dateTime;

- (void)addChatMessage:(MSMessageModel *)chatMessage;


@end
