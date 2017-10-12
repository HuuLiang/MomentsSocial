//
//  MSMessageViewController.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMessageViewController.h"
#import "MSMessageViewController+XHBMessage.h"
#import "MSNavigationController.h"
#import "QBLocationManager.h"
#import "MSMessageModel.h"
//#import "MSReqManager.h"
//#import "QBDataResponse.h"
#import "MSNavigationController.h"
#import "QBVoiceManager.h"

@interface MSMessageViewController ()
@property (nonatomic) BOOL needReturn;
@property (nonatomic) UIButton *locationButton;
@property (nonatomic) BOOL showAllLocation;
@property (nonatomic) NSMutableArray <MSMessageModel *> *chatMessages;
@end

@implementation MSMessageViewController
QBDefineLazyPropertyInitialization(NSMutableArray, chatMessages)


- (instancetype)initWithUserId:(NSInteger)userId
                      nickName:(NSString *)nickName
                   portraitUrl:(NSString *)portraitUrl {
    self = [self init];
    if (self) {
        _userId = [NSString stringWithFormat:@"%ld",(long)userId];
        _nickName = nickName;
        _portraitUrl = portraitUrl;
    }
    return self;
}

+ (instancetype)showMessageWithUserId:(NSInteger)userId
                             nickName:(NSString *)nickName
                          portraitUrl:(NSString *)portraitUrl
                     inViewController:(UIViewController *)viewController {
    MSMessageViewController *messageVC = [[self alloc] initWithUserId:userId nickName:nickName portraitUrl:portraitUrl];
    messageVC.allowsSendFace = NO;
    messageVC.allowsSendMultiMedia = YES;
    [viewController.navigationController pushViewController:messageVC animated:YES];
    return messageVC;
}

+ (instancetype)presentMessageWithUserId:(NSInteger)userId
                                nickName:(NSString *)nickName
                             portraitUrl:(NSString *)portraitUrl
                        inViewController:(UIViewController *)viewController {
    MSMessageViewController *messageVC = [[self alloc] initWithUserId:userId nickName:nickName portraitUrl:portraitUrl];
    messageVC.needReturn = YES;
    messageVC.allowsSendFace = NO;
//    messageVC.allowsSendMultiMedia = NO;
    MSNavigationController *messageNav = [[MSNavigationController alloc] initWithRootViewController:messageVC];
    [viewController presentViewController:messageNav animated:YES completion:nil];
    return messageVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.messageTableView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    self.title = self.nickName;
    self.messageSender = [NSString stringWithFormat:@"%ld",(long)[MSUtil currentUserId]];
    
    if (_needReturn) {
        @weakify(self);
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"返回" style:UIBarButtonItemStylePlain handler:^(id sender) {
            @strongify(self);
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    
    [self setXHShareMenu];                //设置功能菜单
    [self registerCustomVipNoticeCell]; //注册提示的cell样式
    [self configLocationUI];             //设置定位UI
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadChatMessage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePostMessageInfo:) name:kMSPostMessageInfoNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self postLastMessageInfoToContact];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//更新最后一条消息到消息界面
- (void)postLastMessageInfoToContact {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        MSMessageModel *msgModel = [self.chatMessages lastObject];
        if (!msgModel) {
            return ;
        }
        msgModel.portraitUrl = self.portraitUrl;
        msgModel.nickName = self.nickName;
        [MSMessageModel postMessageInfoToContact:msgModel];
    });
}

//接收到推送的消息
- (void)receivePostMessageInfo:(NSNotification *)notification {
    MSMessageModel *msgModel = [notification object];
    if ([msgModel.sendUserId isEqualToString:self.userId]) {
        if ([msgModel saveOrUpdate]) {
            [self.chatMessages addObject:msgModel];
            [self addChatMessageIntoSelf:msgModel reload:NO];
            [[QBVoiceManager manager] playReceiveVoice];
            
            //更新消息阅读状态
            [self changeMsgReadStatus];
        }
    }
}

- (void)changeMsgReadStatus {
    dispatch_async(self.changeMessageDataSourceQueue, ^{
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        [self.messages enumerateObjectsUsingBlock:^(XHMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.sender isEqualToString:self.messageSender]) {
                obj.readDone = YES;
                [self.messages replaceObjectAtIndex:idx withObject:obj];
                [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messageTableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        });
    });
}


//进入页面重新加载所有消息
- (void)reloadChatMessage {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSArray *reverseMsgs = [[[MSMessageModel allMessagesWithUserId:self.userId] reverseObjectEnumerator] allObjects];
        if (reverseMsgs.count == self.chatMessages.count) {
            [self.messageTableView reloadData];
            [self scrollToBottomAnimated:NO];
            return ;
        }
        
        NSMutableArray *allChatMsgs = [[NSMutableArray alloc] init];
        __block BOOL readDone = NO;
        //默认消息未未读 逆序 当遍历到消息发送者为机器人时  则之后的所有用户发出的消息为已读
        [reverseMsgs enumerateObjectsUsingBlock:^(MSMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.sendUserId isEqualToString:self.userId]) {
                readDone = YES;
            }
            if (readDone && [obj.sendUserId isEqualToString:self.messageSender]) {
                obj.readDone = YES;
            }
            [allChatMsgs addObject:obj];
        }];
        
        //设置过阅读状态消息逆序加入聊天数组中 更新到界面里
        [self.chatMessages addObjectsFromArray:[[allChatMsgs reverseObjectEnumerator] allObjects]];
        
        [self.messages removeAllObjects];

        [self.chatMessages enumerateObjectsUsingBlock:^(MSMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [self addChatMessageIntoSelf:obj reload:YES];
        }];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.messageTableView reloadData];
            [self scrollToBottomAnimated:NO];
        });
    });
}

//加载消息到聊天界面中
- (void)addChatMessageIntoSelf:(MSMessageModel *)obj reload:(BOOL)reload {
    XHMessage *message;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:obj.msgTime];
    if (obj.msgType == MSMessageTypeText) {
        message = [[XHMessage alloc] initWithText:obj.msgContent
                                           sender:obj.sendUserId
                                        timestamp:date];
        message.readDone = obj.readDone;
        message.messageMediaType = XHBubbleMessageMediaTypeText;
    } else if (obj.msgType == MSMessageTypePhoto) {
        message = [[XHMessage alloc] initWithPhoto:nil
                                      thumbnailUrl:obj.imgUrl
                                    originPhotoUrl:nil
                                            sender:obj.sendUserId
                                         timestamp:date];
        message.messageMediaType = XHBubbleMessageMediaTypePhoto;
    } else if (obj.msgType == MSMessageTypeVoice) {
        message = [[XHMessage alloc] initWithVoicePath:obj.voiceUrl
                                              voiceUrl:obj.voiceUrl
                                         voiceDuration:obj.voiceDuration
                                                sender:obj.sendUserId
                                             timestamp:date];
        message.messageMediaType = XHBubbleMessageMediaTypeVoice;
    } else if (obj.msgType == MSMessageTypeVideo) {
        message = [[XHMessage alloc] initWithVideoConverPhoto:nil
                                                    videoPath:nil
                                                     videoUrl:obj.videoUrl
                                                       sender:obj.sendUserId
                                                    timestamp:date];
        message.messageMediaType = XHBubbleMessageMediaTypeVideo;
        message.thumbnailUrl = obj.videoImgUrl;
    } else if (obj.msgType == MSMessageTypeFaceTime) {
        message = [[XHMessage alloc] initWithText:@"【视频聊天邀请】"
                                           sender:obj.sendUserId
                                        timestamp:date];
        message.messageMediaType = XHBubbleMessageMediaTypeText;
    } else if (obj.msgType == MSMessageTypeVipNotice) {
        message = [[XHMessage alloc] initWithText:@""
                                           sender:@""
                                        timestamp:date];
        message.messageMediaType = XHBubbleMessageMediaTypeCustom;
    }
    
    if ([obj.sendUserId isEqualToString:self.messageSender]) {
        message.bubbleMessageType = XHBubbleMessageTypeSending;
    } else {
        message.bubbleMessageType = XHBubbleMessageTypeReceiving;
    }
    
    if (reload) {
        [self.messages addObject:message];
    } else {
        [self addMessage:message];
    }
}

/**
 加入一条文本消息
 
 @param message 消息内容
 @param sender 发送者
 @param receiver 接受者
 @param dateTime 发送日期
 */
- (void)addTextMessage:(NSString *)message
            withSender:(NSString *)sender
              receiver:(NSString *)receiver
              dateTime:(NSInteger)dateTime {
    MSMessageModel *chatMessage = [[MSMessageModel alloc] init];
    chatMessage.sendUserId = sender;
    chatMessage.receiveUserId = receiver;
    chatMessage.msgTime = dateTime;
    chatMessage.msgType = MSMessageTypeText;
    chatMessage.msgContent = message;
    chatMessage.readDone = NO;
    chatMessage.nickName = self.nickName;
    chatMessage.portraitUrl = self.portraitUrl;
    [self addChatMessage:chatMessage];
}


/**
 加入一条语音消息
 
 @param voicePath 语音文件路径
 @param voiceDuration 时长
 @param sender 发送者
 @param receiver 接受者
 @param dateTime 发送日期
 */
- (void)addVoiceMessage:(NSString *)voicePath
          voiceDuration:(NSString *)voiceDuration
             withSender:(NSString *)sender
               receiver:(NSString *)receiver
               dateTime:(NSInteger)dateTime {
    MSMessageModel *chatMessage = [[MSMessageModel alloc] init];
    chatMessage.sendUserId = sender;
    chatMessage.receiveUserId = receiver;
    chatMessage.msgTime = dateTime;
    chatMessage.voiceUrl = voicePath;
    chatMessage.voiceDuration = voiceDuration;
    chatMessage.msgType = MSMessageTypeVoice;
    chatMessage.nickName = self.nickName;
    chatMessage.portraitUrl = self.portraitUrl;
    [self addChatMessage:chatMessage];
}


/**
 加入一条图片消息

 @param imgUrl 图片链接
 @param sender 发送者
 @param receiver 接收者
 @param dateTime 发送日期
 */
- (void)addPhotoMessage:(NSString *)imgUrl
             withSender:(NSString *)sender
               receiver:(NSString *)receiver
               dateTime:(NSInteger)dateTime {
    MSMessageModel *chatMessage = [[MSMessageModel alloc] init];
    chatMessage.sendUserId = sender;
    chatMessage.receiveUserId = receiver;
    chatMessage.msgTime = dateTime;
    chatMessage.imgUrl = imgUrl;
    chatMessage.msgType = MSMessageTypePhoto;
    chatMessage.nickName = self.nickName;
    chatMessage.portraitUrl = self.portraitUrl;
    [self addChatMessage:chatMessage];
}

//提示用户付费的vip消息提示
- (void)addVipNoticeMessage {
    MSMessageModel *noticeMsg = [MSMessageModel vipNoticeMessage];
    [self addChatMessageIntoSelf:noticeMsg reload:NO];
    [[QBVoiceManager manager] playReceiveVoice];
}

//用户主动发送的消息的加载方式
- (void)addChatMessage:(MSMessageModel *)chatMessage {
    if ([chatMessage saveOrUpdate] && self.isViewLoaded) {
        [self.chatMessages addObject:chatMessage];
        [self addChatMessageIntoSelf:chatMessage reload:NO];
        [[QBVoiceManager manager] playSendVoice];
    }
    
    if ([MSUtil currentVipLevel] == MSLevelVip0) {
        [self.messageInputView.inputTextView resignFirstResponder];
        [self addVipNoticeMessage];
    }
    
    [MSMessageModel postMessageToServer:chatMessage];
}


/**
 布局定位UI
 */
- (void)configLocationUI {
    //    定位服务不可用 返回
    if (![[QBLocationManager manager] checkLocationIsEnable]) {
        return;
    }
    
    [[QBLocationManager manager] getUserLacationNameWithUserId:self.userId locationName:^(BOOL success,NSString *locationName) {
        if (!success || _locationButton) {
            return ;
        }
        CGFloat width = [locationName sizeWithFont:kFont(10) maxHeight:kFont(10).lineHeight].width;
        
        self.locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_locationButton setImage:[UIImage imageNamed:@"message_location"] forState:UIControlStateNormal];
        [_locationButton setTitle:locationName forState:UIControlStateNormal];
        [_locationButton setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
        _locationButton.titleLabel.font = kFont(10);
        _locationButton.backgroundColor = [kColor(@"#000000") colorWithAlphaComponent:0.5];
        _locationButton.layer.cornerRadius = kWidth(20);
        [self.view addSubview:_locationButton];
        
        _locationButton.imageEdgeInsets = UIEdgeInsetsMake(_locationButton.imageEdgeInsets.top, _locationButton.imageEdgeInsets.left - 3 , _locationButton.imageEdgeInsets.bottom, _locationButton.imageEdgeInsets.right + 3);
        
        @weakify(self);
        [_locationButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            [self.locationButton removeFromSuperview];
            [self.view addSubview:self.locationButton];
            if (!self.showAllLocation) {
                [self.locationButton setTitle:@"" forState:UIControlStateNormal];
                [self.locationButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.view.mas_right).offset(kWidth(20));
                    make.top.equalTo(self.view.mas_top).offset(kWidth(50));
                    make.size.mas_equalTo(CGSizeMake(kWidth(70), kWidth(40)));
                }];
            } else {
                [self.locationButton setTitle:locationName forState:UIControlStateNormal];
                [self.locationButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.view.mas_right).offset(kWidth(20));
                    make.top.equalTo(self.view.mas_top).offset(kWidth(50));
                    make.size.mas_equalTo(CGSizeMake(width + kWidth(70), kWidth(40)));
                }];
            }
            
            self.showAllLocation = !self.showAllLocation;
        } forControlEvents:UIControlEventTouchUpInside];
        
        {
            [self.locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.view.mas_right).offset(kWidth(20));
                make.top.equalTo(self.view.mas_top).offset(kWidth(50));
                make.size.mas_equalTo(CGSizeMake(width + kWidth(70), kWidth(40)));
            }];
        }
    }];
}

@end
