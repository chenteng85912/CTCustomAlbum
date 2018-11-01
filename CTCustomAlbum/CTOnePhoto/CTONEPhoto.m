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

/** @brief 代理对象 */
@property (nonatomic,weak) id <CTONEPhotoDelegate> delegate;
/** @brief 图片选择回调 */
@property (nonatomic, copy) CTONEPhotoBLock photoBlock;
/** @brief 视频选择回调 */
@property (nonatomic, copy) CTONEVideoBLock videoBlock;
//拍照后是否自动保持到相册
@property (nonatomic, assign) BOOL autoSave;

@end

@implementation CTONEPhoto

static CTONEPhoto *onePhoto = nil;

+ (void)sigtonPhoto {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        onePhoto = [[self alloc] init];

    });
    
}

//打开系统摄像头
+ (void)openCameraWithDelegate:(id <CTONEPhotoDelegate>)rootVC
                      autoSave:(BOOL)autoSave
                    enableEdit:(BOOL)enableEdit {

    if (![CTSavePhotos checkAuthorityOfCamera]) {
        return;
    }
    [self sigtonPhoto];
    onePhoto.delegate = rootVC;
    onePhoto.autoSave = autoSave;
    [self p_initCamera:enableEdit];

}
+ (void)openCamera:(BOOL)enableEdit
          autoSave:(BOOL)autoSave
     photoComplete:(CTONEPhotoBLock)photoBlock {
    if (![CTSavePhotos checkAuthorityOfCamera]) {
        return;
    }
    [self sigtonPhoto];
    onePhoto.photoBlock = photoBlock;
    onePhoto.autoSave = autoSave;
    [self p_initCamera:enableEdit];
    
}
//初始化相机
+ (void)p_initCamera:(BOOL)enableEdit {
    [self p_initPicker];

    onePhoto.imagePicker.allowsEditing = enableEdit;
    onePhoto.imagePicker.mediaTypes =  @[(NSString *)kUTTypeImage];
    onePhoto.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [[CTSavePhotos p_currentViewController] presentViewController:onePhoto.imagePicker animated:YES completion:nil];
}
//打开系统相册
+ (void)openAlbum:(CTShowResourceModel)showResourceModel
     withDelegate:(id <CTONEPhotoDelegate>)rootVC
       enableEdit:(BOOL)enableEdit {
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
    videoComplete:(CTONEVideoBLock)videoBlock {
    if (![CTSavePhotos checkAuthorityOfAblum]) {
        return;
    }
    [self sigtonPhoto];
    onePhoto.photoBlock = photoBlock;
    onePhoto.videoBlock = videoBlock;
    [self p_initImage:showResourceModel enableEdit:enableEdit];
}
+ (void)p_initPicker {
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.delegate = onePhoto;
    onePhoto.imagePicker = picker;
}
//初始化相册
+ (void)p_initImage:(CTShowResourceModel)showResourceModel
         enableEdit:(BOOL)enableEdit {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self p_initPicker];
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
    [[CTSavePhotos p_currentViewController] presentViewController:onePhoto.imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
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
        if ([CTSavePhotos checkAuthorityOfAblum]&&onePhoto.autoSave) {
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
                    onePhoto.photoBlock(originImg, imageName);
                }
                [picker dismissViewControllerAnimated:YES completion:nil];
            }];
        }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
            //检测本地缓存大小
            [CTSavePhotos checkLocalCachesSize];
            //视频
            NSURL *vedioURL = [info valueForKey:UIImagePickerControllerMediaURL];
            NSData *videoData = [NSData dataWithContentsOfURL:vedioURL];
            float videoSize = videoData.length/1024.0f/1024.0f;
            //超过剩余空间 弹出提示
            if (videoSize >[CTSavePhotos getFreeDiskspace]) {
                [picker dismissViewControllerAnimated:YES completion:^{
                    [onePhoto p_showAlert];
                }];
                return;
            }
            
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

//视频转码
- (void)p_encode:(NSURL *)url
       withBlock:(void (^) (NSString *fileFullPath, NSString *fileName))block {
  
    //视频格式转换
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    NSString *mp4Quality = AVAssetExportPresetHighestQuality; //AVAssetExportPreset640x480;//
    if ([compatiblePresets containsObject:mp4Quality]){
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset
                                                                              presetName:mp4Quality];
        
        NSString *fileName = [NSString stringWithFormat:@"%.f.mp4", [[NSDate new] timeIntervalSince1970]];
        NSString *mp4Path = [[CTSavePhotos documentPath] stringByAppendingPathComponent:fileName];
        
        exportSession.outputURL = [NSURL fileURLWithPath:mp4Path];
        exportSession.shouldOptimizeForNetworkUse = YES; //是否为网络传输优化
        exportSession.outputFileType = AVFileTypeMPEG4;
        //存入本地
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    //格式转换失败
                    NSLog(@"视频格式转换失败");
                    dispatch_async(dispatch_get_main_queue(), ^{

                        [onePhoto.imagePicker dismissViewControllerAnimated:YES completion:^{
                            
                        }];
                    });
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
- (UIImage *)p_getVideoShotImage:(NSString *)filePath {
    
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
                complete:(void (^)( UIImage* _Nonnull originImg))completeBlock {
    PHImageRequestOptions * option = [[PHImageRequestOptions alloc] init];
    
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    CGSize  size = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        completeBlock(result);
        
    }];
    
}

- (void)p_showAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"你的设备剩余空间不足" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [[CTSavePhotos p_currentViewController] presentViewController:alert animated:YES completion:nil];
}
@end
