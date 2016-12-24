//
//  ONEPhoto.m
//  FacePk
//
//  Created by Apple on 16/7/15.
//  Copyright © 2016年 腾. All rights reserved.
//

#import "CTONEPhoto.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CTSavePhotos.h"
#import "UIImage+Tools.h"

static CTONEPhoto *onePhoto = nil;

@interface CTONEPhoto ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic,strong) UIImagePickerController *imagePicker;
@end

@implementation CTONEPhoto
+ (CTONEPhoto *)shareSigtonPhoto
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
    if (![[CTSavePhotos new] checkAuthorityOfCamera]) {
        return;
    }
    
    onePhoto.imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
    onePhoto.imagePicker.allowsEditing = enableEdit;
  
    [rootVC presentViewController:onePhoto.imagePicker animated:YES completion:nil];
}
- (void)openAlbum:(UIViewController *)rootVC editModal:(BOOL)enableEdit{
    if (![[CTSavePhotos new] checkAuthorityOfAblum]) {
        return;
    }
    //onePhoto.imagePicker.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    onePhoto.imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    onePhoto.imagePicker.allowsEditing = enableEdit;
    onePhoto.imagePicker.navigationBar.translucent = NO;
    onePhoto.imagePicker.navigationBar.tintColor = [UIColor blackColor];
    
    [rootVC presentViewController:onePhoto.imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *selectedImage = nil;
    if (picker.allowsEditing) {
        selectedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    }else{
        selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            selectedImage = [selectedImage normalizedImage];
        }
    }
   
    [picker dismissViewControllerAnimated:YES completion:^{

        if ([onePhoto.delegate respondsToSelector:@selector(sendOnePhoto:)]) {
            [onePhoto.delegate sendOnePhoto:selectedImage];
        }
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            if (![[CTSavePhotos new] checkAuthorityOfAblum]) {
                return;
            }
            
            [[CTSavePhotos new] saveImageIntoAlbum:selectedImage];
            
        }
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{

    [picker dismissViewControllerAnimated:YES completion:nil];
    
}
@end
