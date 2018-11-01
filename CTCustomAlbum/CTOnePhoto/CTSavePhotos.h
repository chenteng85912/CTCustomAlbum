//
//  SaveImageTool.h
//
//  Created by chenteng on 2016/12/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CTSavePhotos : NSObject

/**
 判断相册权限

 @return 返回结果
 */
+ (BOOL)checkAuthorityOfAblum;

/**
 检测相机权限

 @return 返回结果
 */
+ (BOOL)checkAuthorityOfCamera;

/**
 保存图片到相册 自定义分类名称 (根据项目名称命名)
 
 @param image 需要保存的图片
 */
+ (void)saveImageIntoAlbum:(UIImage *)image;


/**
 获取对顶部控制器

 @return 顶部控制器
 */
+ (UIViewController *)p_currentViewController;

+ (BOOL)checkAuthorityofAudio;
/**
 文件存储的本地路径 

 @return 本地路径
 */
+ (NSString *)documentPath;


/**
 获取设备空余空间

 @return 剩余空间大小 M单位
 */
+ (float)getFreeDiskspace;


/**
 检测剩余空间 超过100M 自动清理
 */
+ (void)checkLocalCachesSize;

@end
