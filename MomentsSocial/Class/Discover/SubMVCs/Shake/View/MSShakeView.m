//
//  MSShakeView.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/1.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSShakeView.h"
#import <AVFoundation/AVFoundation.h>

static NSString *const kMSShakeVoiceStartFileName = @"shake_start";
static NSString *const kMSShekeVoiceEndFileName   = @"shake_end";

@interface MSShakeView ()
@property (nonatomic) UIImageView *upImgV;
@property (nonatomic) UIImageView *downImgV;
@property (nonatomic) UIImageView *backImgV;
@end

@implementation MSShakeView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = kColor(@"#2C2E30");
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
        
        self.backImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shake_back"]];
        [self addSubview:_backImgV];
        
        self.upImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shake_up"]];
        [self addSubview:_upImgV];
        
        self.downImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shake_down"]];
        [self addSubview:_downImgV];
        
        {
            [_backImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.size.mas_equalTo(CGSizeMake(kWidth(130), kWidth(162)));
            }];
            
            [_upImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.bottom.equalTo(self.mas_centerY);
                make.size.mas_equalTo(CGSizeMake(kWidth(196), kWidth(140)));
            }];
            
            [_downImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self.mas_centerY);
                make.size.mas_equalTo(CGSizeMake(kWidth(196), kWidth(140)));
            }];
        }
    }
    return self;
}

- (void)shakeStart {
    
    CGRect upFrame = _upImgV.frame;
    CGRect downFrame = _downImgV.frame;

    [UIView animateWithDuration:0.75 animations:^{
        [self playVoiceWithFileName:kMSShakeVoiceStartFileName];

        _upImgV.transform = CGAffineTransformMakeTranslation(0, -kWidth(100));
        _downImgV.transform = CGAffineTransformMakeTranslation(0, kWidth(100));
        _upImgV.frame = CGRectMake(upFrame.origin.x, upFrame.origin.y-kWidth(100), upFrame.size.width, upFrame.size.height);
        _downImgV.frame = CGRectMake(downFrame.origin.x, downFrame.origin.y+kWidth(100), downFrame.size.width, downFrame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.75 animations:^{
            _upImgV.transform = CGAffineTransformMakeTranslation(0, kWidth(100));
            _downImgV.transform = CGAffineTransformMakeTranslation(0, -kWidth(100));
            _upImgV.frame = upFrame;
            _downImgV.frame = downFrame;
            
//            if (self.startFetchAction) {
//                self.startFetchAction();
//            }
        }];
    }];
}

- (void)shakeEnd {
    [self playVoiceWithFileName:kMSShekeVoiceEndFileName];
}

- (void)playVoiceWithFileName:(NSString *)fileName {
    SystemSoundID soundId;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:filePath], &soundId);
    AudioServicesPlaySystemSound(soundId);
}

- (void)setShakeStatus:(MSShakeStatus)shakeStatus {
    switch (shakeStatus) {
        case MSShakeStatusStart:
            QBLog(@"开始");
            [self shakeStart];
            break;
            
        case MSShakeStatusEnd:
            QBLog(@"结束");
            [self shakeEnd];
            break;
        
        case MSShakeStatusCancle:
            
            break;
            
        default:
            break;
    }
}

@end
