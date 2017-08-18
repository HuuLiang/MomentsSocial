//
//  MSMessageViewController+XHBMessage.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMessageViewController+XHBMessage.h"
#import "MSDetailViewController.h"
#import "QBPhotoBrowser.h"
#import "XHAudioPlayerHelper.h"
#import <AVFoundation/AVFoundation.h>
#import "QBVideoPlayer.h"
#import "MSMsgVipNoticeCell.h"
#import "MSVipVC.h"

static NSString *const kMSMessageVipNoticeCellReusableIdentifier = @"kMSMessageVipNoticeCellReusableIdentifier";

@implementation MSMessageViewController (XHBMessage)

#pragma mark - XHMessageTableViewControllerDelegate

//发送文本
- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    [self addTextMessage:text withSender:sender receiver:self.userId dateTime:[date timeIntervalSince1970]];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];
    [self scrollToBottomAnimated:YES];
}

//发送语音
- (void)didSendVoice:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration fromSender:(NSString *)sender onDate:(NSDate *)date {
    [self addVoiceMessage:voicePath voiceDuration:voiceDuration withSender:sender receiver:self.userId dateTime:[date timeIntervalSince1970]];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeVoice];
    [self scrollToBottomAnimated:YES];
}

//是否显示时间轴
- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    XHMessage *previousMessage = indexPath.row > 0 ? self.messages[indexPath.row-1] : nil;
    if (previousMessage) {
        XHMessage *currentMessage = self.messages[indexPath.row];
        if ([currentMessage.timestamp isEqualToDateIgnoringSecond:previousMessage.timestamp]) {
            return NO;
        }
    }
    return YES;
}

//配置cell样式
- (void)configureCell:(XHMessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    XHMessage *message = self.messages[indexPath.row];
    
    if ([message.sender isEqualToString:self.messageSender]) {
        [cell.avatarButton sd_setImageWithURL:[NSURL URLWithString:[MSUtil currentProtraitUrl]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_Img"]];
    } else {
        [cell.avatarButton sd_setImageWithURL:[NSURL URLWithString:self.portraitUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_Img"]];;
    }
    
}

//配置自定义cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath targetMessage:(id<XHMessageModel>)message {
    return kWidth(60);
}

//配置自定义cell样式
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath targetMessage:(id<XHMessageModel>)message {
    message = (XHMessage *)message;
    MSMsgVipNoticeCell *cell;
    if (message.messageMediaType == XHBubbleMessageMediaTypeCustom) {
        cell = (MSMsgVipNoticeCell *)[tableView dequeueReusableCellWithIdentifier:kMSMessageVipNoticeCellReusableIdentifier forIndexPath:indexPath];
        
        @weakify(self);
        cell.noticeAction = ^{
            [[MSPopupHelper helper] showPopupViewWithType:MSPopupTypeSendMessage disCount:NO cancleAction:nil confirmAction:^{
                @strongify(self);
                [MSVipVC showVipViewControllerInCurrentVC:self];
            }];
        };
    }
    return cell;
}

- (void)registerCustomVipNoticeCell {
    [self.messageTableView registerClass:[MSMsgVipNoticeCell class] forCellReuseIdentifier:kMSMessageVipNoticeCellReusableIdentifier];
}

#pragma mark - XHMessageTableViewCellDelegate

/**
 *  点击多媒体消息的时候统一触发这个回调
 *
 *  @param message   被操作的目标消息Model
 *  @param indexPath 该目标消息在哪个IndexPath里面
 *  @param messageTableViewCell 目标消息在该Cell上
 */
- (void)multiMediaMessageDidSelectedOnMessage:(id <XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(XHMessageTableViewCell *)messageTableViewCell {
    if (message.messageMediaType == XHBubbleMessageMediaTypePhoto && message.thumbnailUrl) {
        //图片浏览
        [[QBPhotoBrowser browse] showPhotoBrowseWithImageUrl:@[message.thumbnailUrl] atIndex:0 needBlur:NO blurStartIndex:0 onSuperView:self.view handler:nil];
    } else if (message.messageMediaType == XHBubbleMessageMediaTypeVoice) {
        //语音消息
        message.isRead = YES;
        messageTableViewCell.messageBubbleView.voiceUnreadDotImageView.hidden = YES;
        
        [[XHAudioPlayerHelper shareInstance] setDelegate:(id<NSFileManagerDelegate>)self];
        if (self.currentSelectedCell) {
            [self.currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
        }
        if (self.currentSelectedCell == messageTableViewCell) {
            [messageTableViewCell.messageBubbleView.animationVoiceImageView stopAnimating];
            [[XHAudioPlayerHelper shareInstance] stopAudio];
            self.currentSelectedCell = nil;
        } else {
            self.currentSelectedCell = messageTableViewCell;
            [messageTableViewCell.messageBubbleView.animationVoiceImageView startAnimating];
            if ([message.sender isEqualToString:self.userId]) {
                NSURL * url  = [NSURL URLWithString:message.voiceUrl];
                AVPlayerItem * songItem = [[AVPlayerItem alloc]initWithURL:url];
                self.player = [[AVPlayer alloc] initWithPlayerItem:songItem];
                [self.player play];
            } else {
                [[XHAudioPlayerHelper shareInstance] managerAudioWithFileName:message.voicePath toPlay:YES];
            }
        }
    } else if (message.messageMediaType == XHBubbleMessageMediaTypeVideo) {
        //视频播放
        QBVideoPlayer * _videoPlayer = [[QBVideoPlayer alloc] initWithVideoURL:[NSURL URLWithString:message.videoUrl]];
        [self.view addSubview:_videoPlayer];
        {
            [_videoPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
        }
        [_videoPlayer startToPlay];
        
        @weakify(_videoPlayer);
        _videoPlayer.endPlayAction = ^(id obj) {
            @strongify(_videoPlayer);
            [_videoPlayer pause];
            [_videoPlayer removeFromSuperview];
            _videoPlayer = nil;
        };
    }
}
#pragma mark - XHAudioPlayerHelper Delegate

- (void)didAudioPlayerStopPlay:(AVAudioPlayer *)audioPlayer {
    if (self.currentSelectedCell) {
        return;
    }
    [self.currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
    self.currentSelectedCell = nil;
}

/**
 *  双击文本消息，触发这个回调
 *
 *  @param message   被操作的目标消息Model
 *  @param indexPath 该目标消息在哪个IndexPath里面
 */
- (void)didDoubleSelectedOnTextMessage:(id <XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
    //    XHMessage *message = self.messages[indexPath.row];
    
}

/**
 *  点击消息发送者的头像回调方法
 *
 *  @param indexPath 该目标消息在哪个IndexPath里面
 */
- (void)didSelectedAvatarOnMessage:(id <XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
    if (![message.sender isEqualToString:self.messageSender] ) {
        MSDetailViewController *detailVC = [[MSDetailViewController alloc] initWithUserId:self.userId];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}
@end
