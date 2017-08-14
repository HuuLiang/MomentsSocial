//
//  QBPhotoBrowser.h
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BrowseHandler)(void);

@interface QBPhotoBrowser : UIView

+ (instancetype)browse;

- (void)showPhotoBrowseWithImageUrl:(NSArray *)imageUrls
                            atIndex:(NSInteger)currentIndex
                           needBlur:(BOOL)needBlur
                     blurStartIndex:(NSInteger)blurStartIndex
                        onSuperView:(UIView *)superView handler:(BrowseHandler)handler;

- (void)closeBrowse;

@property (nonatomic) QBAction closeAction;

@end
