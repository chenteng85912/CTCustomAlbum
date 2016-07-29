//
//  ONEPhoto.m
//  FacePk
//
//  Created by Apple on 16/7/15.
//  Copyright © 2016年 腾. All rights reserved.
//

#import "ONEPhoto.h"

static ONEPhoto *onePhoto = nil;

@interface ONEPhoto ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic,strong)  UIImagePickerController *imagePicker;

@end
@implementation ONEPhoto
+ (ONEPhoto *)shareSigtonPhoto
{
    @synchronized(self){
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            onePhoto = [[self alloc] init];
            UIImagePickerController *picker = [[UIImagePickerController alloc]init];
            picker.delegate = onePhoto;
            onePhoto.imagePicker = picker;
        });
    }
    
    return onePhoto;
}

- (void)openCamera:(UIViewController *)rootVC editModal:(BOOL)enableEdit{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //相机不可用
        return;
    }
    onePhoto.imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
    onePhoto.imagePicker.allowsEditing = enableEdit;
    [rootVC presentViewController:onePhoto.imagePicker animated:YES completion:nil];
}
- (void)openAlbum:(UIViewController *)rootVC editModal:(BOOL)enableEdit{
   
    //onePhoto.imagePicker.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    onePhoto.imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    onePhoto.imagePicker.allowsEditing = enableEdit;
    onePhoto.imagePicker.navigationBar.translucent = NO;
    onePhoto.imagePicker.navigationBar.tintColor = [UIColor blackColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [rootVC presentViewController:onePhoto.imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *selectedImage = nil;
    if (picker.allowsEditing) {
        selectedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    }else{
        selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];

    }
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum([info objectForKey:UIImagePickerControllerOriginalImage], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);

    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        if ([onePhoto.delegate respondsToSelector:@selector(sendOnePhoto:)]) {
            [onePhoto.delegate sendOnePhoto:selectedImage];
        }
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    NSLog(@"刚刚拍摄的照片已经保存到相册");
}
@end
