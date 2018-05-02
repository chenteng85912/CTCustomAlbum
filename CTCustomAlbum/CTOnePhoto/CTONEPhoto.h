//
//  ONEPhoto.h
//
//  Created by chenteng on 16/7/15.
//  Copyright © 2016年 腾. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 选择图片回调

 @param image 图片对象
 @param imageName 时间戳生成的图片名称
 */
typedef void (^CTONEPhotoBLock)(UIImage * image, NSString *imageName);

/**
 选择视频回调

 @param videoPath 视频本地地址
 @param videoName 视频文件名称
 @param videoShotImage 视频截图
 */
typedef void (^CTONEVideoBLock)(NSString *videoPath, NSString *videoName,UIImage *videoShotImage);

typedef NS_ENUM(NSInteger , CTShowResourceModel) {
    CTShowAlbumImageModel,          //系统相册 图片
    CTShowAlbumImageAndVideoModel,  //系统相册 图片+视频
    CTShowAlbumVideoModel           //系统视频
};

@protocol CTONEPhotoDelegate <NSObject>

@optional

/**
 传出图片

 @param image 图片对象
 @param imageName 时间戳生成的图片名称
 */
- (void)sendOnePhoto:(UIImage *)image
       withImageName:(NSString *)imageName;

/**
 传出视频

 @param videoPath 视频路径
 @param videoName 视频名称
 @param videoShotImage 视频截图
 */
- (void)sendVideoPath:(NSString *)videoPath
            videoName:(NSString *)videoName
       videoShotImage:(UIImage *)videoShotImage;

@end

@interface CTONEPhoto : NSObject

/**
 打开系统相机

 @param rootVC 遵循 CTONEPhotoDelegate 协议的对象
 @param autoSave 拍照后是否存入系统相册
 @param enableEdit 是否打开系统编辑功能
 */
+ (void)openCameraWithDelegate:(id <CTONEPhotoDelegate>)rootVC
                      autoSave:(BOOL)autoSave
                    enableEdit:(BOOL)enableEdit;

/**
 打开系统相机
 
 @param enableEdit 是否打开系统编辑功能
 @param autoSave 拍照后是否存入系统相册
 @param photoBlock 返回选择的资源
 */
+ (void)openCamera:(BOOL)enableEdit
          autoSave:(BOOL)autoSave
     photoComplete:(CTONEPhotoBLock)photoBlock;

/**
  打开系统相册

 @param showResourceModel 显示内容的样式
 @param rootVC 遵循 CTONEPhotoDelegate 协议的对象
 @param enableEdit 是否打开系统编辑功能
 */
+ (void)openAlbum:(CTShowResourceModel)showResourceModel
     withDelegate:(id <CTONEPhotoDelegate>)rootVC
       enableEdit:(BOOL)enableEdit;

/**
 打开系统相册

 @param showResourceModel 显示内容的样式
 @param enableEdit 是否打开系统编辑功能
 @param photoBlock 返回选择的图片资源
 @param videoBlock 返回选择的视频资源
 */
+ (void)openAlbum:(CTShowResourceModel)showResourceModel
       enableEdit:(BOOL)enableEdit
    photoComplete:(CTONEPhotoBLock)photoBlock
    videoComplete:(CTONEVideoBLock)videoBlock;

@end
