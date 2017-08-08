//
//  XHPhotographyHelper.m
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-5-3.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHPhotographyHelper.h"
#import "XHMacro.h"

@interface XHPhotographyHelper () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, copy) DidFinishTakeMediaCompledBlock didFinishTakeMediaCompled;

@end

@implementation XHPhotographyHelper

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    self.didFinishTakeMediaCompled = nil;
}

- (void)showOnPickerViewControllerSourceType:(UIImagePickerControllerSourceType)sourceType onViewController:(UIViewController *)viewController compled:(DidFinishTakeMediaCompledBlock)compled {
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        NSString *sourceTypeTitle = sourceType == UIImagePickerControllerSourceTypePhotoLibrary ? @"相册":@"相机";
        [[MSHudManager manager] showHudWithTitle:sourceTypeTitle message:[NSString stringWithFormat:@"请在设备的\"设置-隐私-%@\"中允许访问%@",sourceTypeTitle,sourceTypeTitle]];
        compled(nil, nil);
        return;
    }
    self.didFinishTakeMediaCompled = [compled copy];
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.editing = YES;
    imagePickerController.delegate = self;
    imagePickerController.sourceType = sourceType;
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.mediaTypes =  [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    [viewController presentViewController:imagePickerController animated:YES completion:NULL];
}

- (void)dismissPickerViewController:(UIImagePickerController *)picker {
    WEAKSELF
    [picker dismissViewControllerAnimated:YES completion:^{
        weakSelf.didFinishTakeMediaCompled = nil;
    }];
}

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
//    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera || picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
//        if (self.didFinishTakeMediaCompled) {
//            self.didFinishTakeMediaCompled(image, editingInfo);
//        }
//        [self dismissPickerViewController:picker];
//    }
//}

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    if (self.didFinishTakeMediaCompled) {
//        self.didFinishTakeMediaCompled(nil, info);
//    }
//    [self dismissPickerViewController:picker];
//}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera || picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        if (self.didFinishTakeMediaCompled) {
            self.didFinishTakeMediaCompled(nil, info);
        }
        [self dismissPickerViewController:picker];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissPickerViewController:picker];
}

@end
