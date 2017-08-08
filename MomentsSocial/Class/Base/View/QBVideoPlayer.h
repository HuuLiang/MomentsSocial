//
//  QBVideoPlayer.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QBVideoPlayer : UIView

@property (nonatomic,copy) QBAction endPlayAction;

@property (nonatomic) NSURL *videoURL;

- (instancetype)initWithVideoURL:(NSURL *)videoURL;

- (void)startToPlay;

- (void)pause;

@end
