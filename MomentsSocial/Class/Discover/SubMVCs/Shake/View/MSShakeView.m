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
        
        self.backgroundColor = kColor(@"#000000");
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
        
        self.backImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        _backImgV.backgroundColor = [UIColor yellowColor];
        [self addSubview:_backImgV];
        
        self.upImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        _upImgV.backgroundColor = [UIColor blueColor];
        [self addSubview:_upImgV];
        
        self.downImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        _downImgV.backgroundColor = [UIColor grayColor];
        [self addSubview:_downImgV];
        
        {
            [_backImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.size.mas_equalTo(CGSizeMake(kWidth(100), kWidth(200)));
            }];
            
            [_upImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.bottom.equalTo(self.mas_centerY);
                make.size.mas_equalTo(CGSizeMake(kWidth(100), kWidth(200)));
            }];
            
            [_downImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self.mas_centerY);
                make.size.mas_equalTo(CGSizeMake(kWidth(100), kWidth(200)));
            }];
        }
    }
    return self;
}

- (void)shakeStart {
    [self playVoiceWithFileName:kMSShakeVoiceStartFileName];
    [UIView animateWithDuration:1 animations:^{
        _upImgV.transform = CGAffineTransformMakeTranslation(0, -kWidth(100));
        _downImgV.transform = CGAffineTransformMakeTranslation(0, kWidth(100));
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 animations:^{
            _upImgV.transform = CGAffineTransformMakeTranslation(0, kWidth(100));
            _downImgV.transform = CGAffineTransformMakeTranslation(0, -kWidth(100));
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
