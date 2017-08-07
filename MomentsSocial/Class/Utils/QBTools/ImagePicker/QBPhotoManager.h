//
//  QBPhotoManager.h
//  ShareAdvertApp
//
//  Created by Liang on 2017/7/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ImagePicker)(UIImage *pickerImage,NSString *keyName);

@interface QBPhotoManager : NSObject

+ (instancetype)manager;

- (void)getImageInCurrentViewController:(UIViewController *)viewController handler:(ImagePicker)picker;

@end
