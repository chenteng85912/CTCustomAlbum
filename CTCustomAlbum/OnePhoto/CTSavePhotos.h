//
//  SaveImageTool.h
//  webhall
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

@end
