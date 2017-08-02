//
//  MSHudManager.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSHudManager.h"
#import <MBProgressHUD.h>


@interface MSHudManager ()
@property (nonatomic,retain) MBProgressHUD *textHud;
@property (nonatomic,retain) MBProgressHUD *progressHud;
@end

@implementation MSHudManager
+(instancetype)manager {
    static MSHudManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MSHudManager alloc] init];
    });
    return _instance;
}

- (UIView *)hudView {
    return self.textHud;
}

-(instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    UIWindow *keyWindow = [[UIApplication sharedApplication].delegate window];
    self.textHud = [[MBProgressHUD alloc] initWithWindow:keyWindow];
    self.textHud.userInteractionEnabled = NO;
    self.textHud.mode = MBProgressHUDModeText;
    self.textHud.minShowTime = 2;
    self.textHud.detailsLabelFont = [UIFont systemFontOfSize:16.];
    self.textHud.labelFont = [UIFont systemFontOfSize:20.];
    //self.textHud.yOffset = [UIScreen mainScreen].bounds.size.height / 4;
    [keyWindow addSubview:self.textHud];
    
    return self;
}

-(void)showHudWithText:(NSString *)text {
    if (text) {
        if (text.length < 10) {
            self.textHud.labelText = text;
            self.textHud.detailsLabelText = nil;
        } else {
            self.textHud.labelText = nil;
            self.textHud.detailsLabelText = text;
        }
        
        [self.textHud show:YES];
        [self.textHud hide:YES];
    }
}

-(void)showHudWithTitle:(NSString *)title message:(NSString *)msg {
    self.textHud.labelText = title;
    self.textHud.detailsLabelText = msg;
    
    [self.textHud show:YES];
    [self.textHud hide:YES];
}

- (MBProgressHUD *)progressHud {
    if (_progressHud) {
        return _progressHud;
    }
    
    UIWindow *keyWindow = [[UIApplication sharedApplication].delegate window];
    _progressHud = [[MBProgressHUD alloc] initWithWindow:keyWindow];
    _progressHud.userInteractionEnabled = NO;
    _progressHud.mode = MBProgressHUDModeIndeterminate;
    _progressHud.minShowTime = 2;
    [keyWindow addSubview:_progressHud];
    return _progressHud;
}
- (void)showProgressInDuration:(NSTimeInterval)duration {
    self.progressHud.minShowTime = duration;
    [self.progressHud show:YES];
    [self.progressHud hide:YES];
}

- (void)showProlgressShowTitle:(NSString *)title withDuration:(NSTimeInterval)duration progress:(CGFloat)progress completeHanlder:(void(^)(void))completeHanlder{
    if (progress == 0) {
        self.progressHud.mode = MBProgressHUDModeAnnularDeterminate;
        self.progressHud.labelText = title;
        self.progressHud.minShowTime = duration;
        //        [self.progressHud show:YES];
        
        [self.progressHud hide:YES];
        
        [self.progressHud showAnimated:YES whileExecutingBlock:^{
            
        } completionBlock:^{
            completeHanlder();
        }];
    }
    
    self.progressHud.progress = progress;
}

@end
