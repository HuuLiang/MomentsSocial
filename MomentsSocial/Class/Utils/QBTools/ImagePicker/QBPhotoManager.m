//
//  QBPhotoManager.m
//  ShareAdvertApp
//
//  Created by Liang on 2017/7/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "QBPhotoManager.h"
#import <CommonCrypto/CommonDigest.h>

typedef void(^DidFinishTakeMediaCompledBlock)(UIImage *image, NSDictionary *editingInfo);

@interface QBPhotoManager () <UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate>
@property (nonatomic, copy) DidFinishTakeMediaCompledBlock didFinishTakeMediaCompled;
@end

@implementation QBPhotoManager

+ (instancetype)manager {
    static QBPhotoManager *_photoManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _photoManager = [[QBPhotoManager alloc] init];
    });
    return _photoManager;
}

- (void)getImageInCurrentViewController:(UIViewController *)viewController handler:(ImagePicker)picker {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择图片获取方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"选择相册",@"选择相机", nil];
    [actionSheet showInView:viewController.view];
    
    @weakify(self);
    void (^PickerMediaBlock)(UIImage *image, NSDictionary *editingInfo) = ^(UIImage *image, NSDictionary *editingInfo) {
        @strongify(self);
        UIImage *originalImage = editingInfo[UIImagePickerControllerOriginalImage];
        if (originalImage) {
            picker(originalImage,[self getMd5ImageKeyNameWithImage:originalImage]);
        } else {
//            [[SAHudManager manager] showHudWithText:@"图片获取失败"];
            NSLog(@"图片获取失败");
        }
    };
    
    [actionSheet bk_setHandler:^{
        @strongify(self);
        //相册
        [self showOnPickerViewControllerSourceType:UIImagePickerControllerSourceTypePhotoLibrary onViewController:viewController compled:PickerMediaBlock];
    } forButtonAtIndex:0];
    
    [actionSheet bk_setHandler:^{
        @strongify(self);
        //相机
        [self showOnPickerViewControllerSourceType:UIImagePickerControllerSourceTypeCamera onViewController:viewController compled:PickerMediaBlock];
    } forButtonAtIndex:1];
}

- (NSString *)getMd5ImageKeyNameWithImage:(UIImage *)image {
    
    NSData *sourceData = UIImageJPEGRepresentation(image, 1.0);
    
    if (!sourceData) {
        return nil;//判断sourceString如果为空则直接返回nil。
    }
    //需要MD5变量并且初始化
    CC_MD5_CTX  md5;
    CC_MD5_Init(&md5);
    //开始加密(第一个参数：对md5变量去地址，要为该变量指向的内存空间计算好数据，第二个参数：需要计算的源数据，第三个参数：源数据的长度)
    CC_MD5_Update(&md5, sourceData.bytes, (CC_LONG)sourceData.length);
    //声明一个无符号的字符数组，用来盛放转换好的数据
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    //将数据放入result数组
    CC_MD5_Final(result, &md5);
    //将result中的字符拼接为OC语言中的字符串，以便我们使用。
    NSMutableString *resultString = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultString appendFormat:@"%02X",result[i]];
    }
    //    NSLog(@"resultString=========%@",resultString);
    return  resultString;
}

- (void)showOnPickerViewControllerSourceType:(UIImagePickerControllerSourceType)sourceType onViewController:(UIViewController *)viewController compled:(DidFinishTakeMediaCompledBlock)compled {
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        NSString *sourceTypeTitle = sourceType == UIImagePickerControllerSourceTypePhotoLibrary ? @"相册":@"相机";
//        [[SAHudManager manager] showHudWithTitle:sourceTypeTitle message:[NSString stringWithFormat:@"请在设备的\"设置-隐私-%@\"中允许访问%@",sourceTypeTitle,sourceTypeTitle]];
        NSLog(@"请在设备的\"设置-隐私-%@\"中允许访问%@",sourceTypeTitle,sourceTypeTitle);
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
    __weak typeof(self) WeakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        WeakSelf.didFinishTakeMediaCompled = nil;
    }];
}

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
