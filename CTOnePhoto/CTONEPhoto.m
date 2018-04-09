//
//  ONEPhoto.m
//
//  Created by chenteng on 16/7/15.
//  Copyright © 2016年 腾. All rights reserved.
//

#import "CTONEPhoto.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CTSavePhotos.h"

@interface CTONEPhoto ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic,strong) UIImagePickerController *imagePicker;

@property (nonatomic,weak) id <CTONEPhotoDelegate> delegate;

/** @brief 图片选择回调 */
@property (nonatomic, copy) CTONEPhotoBLock photoBlock;
/** @brief 视频选择回调 */
@property (nonatomic, copy) CTONEVideoBLock videoBlock;

@end

@implementation CTONEPhoto
static CTONEPhoto *onePhoto = nil;

+ (void)sigtonPhoto
{
   
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        onePhoto = [[self alloc] init];
        UIImagePickerController *picker = [UIImagePickerController new];
        picker.delegate = onePhoto;
        onePhoto.imagePicker = picker;
    });
    
}

//打开系统摄像头
+ (void)openCameraWithDelegate:(id <CTONEPhotoDelegate>)rootVC
                    enableEdit:(BOOL)enableEdit{

    if (![CTSavePhotos checkAuthorityOfCamera]) {
        return;
    }
    [self sigtonPhoto];
    onePhoto.delegate = rootVC;
    [self p_initCamera:enableEdit];

}
+ (void)openCamera:(BOOL)enableEdit
     photoComplete:(CTONEPhotoBLock)photoBlock{
    if (![CTSavePhotos checkAuthorityOfCamera]) {
        return;
    }
    [self sigtonPhoto];
    onePhoto.photoBlock = photoBlock;
    [self p_initCamera:enableEdit];
    
}
//初始化相机
+ (void)p_initCamera:(BOOL)enableEdit{
    onePhoto.imagePicker.allowsEditing = enableEdit;
    onePhoto.imagePicker.mediaTypes =  @[(NSString *)kUTTypeImage];
    onePhoto.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [[self p_currentViewController] presentViewController:onePhoto.imagePicker animated:YES completion:nil];
}
//打开系统相册
+ (void)openAlbum:(CTShowResourceModel)showResourceModel
     withDelegate:(id <CTONEPhotoDelegate>)rootVC
       enableEdit:(BOOL)enableEdit{
    if (![CTSavePhotos checkAuthorityOfAblum]) {
        return;
    }
    [self sigtonPhoto];
    onePhoto.delegate = rootVC;
    
    [self p_initImage:showResourceModel enableEdit:enableEdit];

}
+ (void)openAlbum:(CTShowResourceModel)showResourceModel
       enableEdit:(BOOL)enableEdit
    photoComplete:(CTONEPhotoBLock)photoBlock
    videoComplete:(CTONEVideoBLock)videoBlock{
    if (![CTSavePhotos checkAuthorityOfAblum]) {
        return;
    }
    [self sigtonPhoto];
    onePhoto.photoBlock = photoBlock;
    onePhoto.videoBlock = videoBlock;
    [self p_initImage:showResourceModel enableEdit:enableEdit];
}
//初始化相册
+ (void)p_initImage:(CTShowResourceModel)showResourceModel
         enableEdit:(BOOL)enableEdit
{
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    onePhoto.imagePicker.allowsEditing = enableEdit;
    onePhoto.imagePicker.navigationBar.tintColor = [UIColor blackColor];
    
    switch (showResourceModel) {
        case CTShowAlbumImageModel:
            
            onePhoto.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            onePhoto.imagePicker.mediaTypes =  @[(NSString *)kUTTypeImage];
            
            break;
        case CTShowAlbumVideoModel:
            onePhoto.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            onePhoto.imagePicker.mediaTypes =  @[(NSString *)kUTTypeMovie];
            
            break;
        case CTShowAlbumImageAndVideoModel:
            onePhoto.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            onePhoto.imagePicker.mediaTypes =  @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
            
            break;
    }
    [[self p_currentViewController] presentViewController:onePhoto.imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *selectedImage = nil;
    if (picker.allowsEditing) {
        selectedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    }else{
        selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            selectedImage = [self p_normalizedImage:selectedImage];
        }
    }
    //拍照
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        //保存到相册
        if ([CTSavePhotos checkAuthorityOfAblum]) {
            [CTSavePhotos saveImageIntoAlbum:selectedImage];

        }
        
        NSString *imageName = [NSString stringWithFormat:@"%f.JPG",[[NSDate new]timeIntervalSince1970]];
        [picker dismissViewControllerAnimated:YES completion:^{
            if ([onePhoto.delegate respondsToSelector:@selector(sendOnePhoto:withImageName:)]) {
                [onePhoto.delegate sendOnePhoto:selectedImage withImageName:imageName];
            }
         
            if (onePhoto.photoBlock) {
                onePhoto.photoBlock(selectedImage, imageName);
            }
        }];
       
    }else{
        NSString *mediaType = info[UIImagePickerControllerMediaType];
        //图片
        if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
            //相册 取出图片名称
            
            NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];

            PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[imageURL] options:nil];

            [self p_fetchOriginImage:result.firstObject complete:^(UIImage * _Nonnull originImg) {
                NSString *imageName = [result.firstObject valueForKey:@"filename"];
                if ([onePhoto.delegate respondsToSelector:@selector(sendOnePhoto:withImageName:)]) {
                    [onePhoto.delegate sendOnePhoto:originImg withImageName:imageName];
                }
                if (onePhoto.photoBlock) {
                    onePhoto.photoBlock(selectedImage, imageName);
                }
                [onePhoto.imagePicker dismissViewControllerAnimated:YES completion:^{
                }];
            }];
        }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
            //视频
            NSURL *vedioURL = [info valueForKey:UIImagePickerControllerMediaURL];
            [onePhoto p_encode:vedioURL withBlock:^(NSString *fileFullPath, NSString *fileName) {
                [picker dismissViewControllerAnimated:YES completion:^{

                    if ([onePhoto.delegate respondsToSelector:@selector(sendVideoPath:videoName:videoShotImage:)]) {
                        [onePhoto.delegate sendVideoPath:fileFullPath videoName:fileName videoShotImage:[onePhoto p_getVideoShotImage:fileFullPath]];
                    }
                    if (onePhoto.videoBlock) {
                        onePhoto.videoBlock(fileFullPath, fileName, [onePhoto p_getVideoShotImage:fileFullPath]);
                    }
                }];
            }];
        }
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{

    [picker dismissViewControllerAnimated:YES completion:^{
    }];
    
}
//视频转码
- (void)p_encode:(NSURL *)url
     withBlock:(void (^) (NSString *fileFullPath, NSString *fileName))block
{
    
    NSURL *doneUrl =[NSURL new];
    //视频格式转换
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    NSString *mp4Quality = AVAssetExportPresetMediumQuality; //AVAssetExportPreset640x480;//
    if ([compatiblePresets containsObject:mp4Quality]){
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:mp4Quality];
        
        NSString *doc=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *fileName = [NSString stringWithFormat:@"%.f.mp4", [[NSDate new] timeIntervalSince1970]];
        NSString *mp4Path = [NSString stringWithFormat:@"%@/%@", doc, fileName];
        
        doneUrl = [NSURL fileURLWithPath:mp4Path];
        exportSession.outputURL = doneUrl;
        exportSession.shouldOptimizeForNetworkUse = YES; //是否为网络传输优化
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    //格式转换失败
                    NSLog(@"视频格式转换失败");
                    break;
                }
                    
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"视频格式转换取消");
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    
                    //回主线程
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"视频格式转换成功,视频路径：%@",mp4Path);

                        //block回调
                        if (block) {
                            block(mp4Path, fileName);
                        }
                    });
                    
                }
                    break;
                default:
                    break;
            }
            
        }];
    }
}
//获取视频截图
- (UIImage *)p_getVideoShotImage:(NSString *)filePath{
    
    UIImage *shotImage;
    //视频路径URL
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    shotImage = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    
    return shotImage;
    
}
//正常摆正图片方向
- (UIImage *)p_normalizedImage:(UIImage *)originImg {
    if (originImg.imageOrientation == UIImageOrientationUp)
        return originImg;
    
    UIGraphicsBeginImageContextWithOptions(originImg.size, NO, originImg.scale);
    [originImg drawInRect:(CGRect){0, 0, originImg.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}
//获取图片
- (void)p_fetchOriginImage:(PHAsset *)asset
                complete:(void (^)( UIImage* _Nonnull originImg))completeBlock
{
    PHImageRequestOptions * option = [[PHImageRequestOptions alloc] init];
    
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    CGSize  size = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        completeBlock(result);
        
    }];
    
}
//获取最顶部控制器
+ (UIViewController *)p_currentViewController {
    
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1)
    {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController *)vc).selectedViewController;
        }else if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController *)vc).visibleViewController;
        }else if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}

@end
