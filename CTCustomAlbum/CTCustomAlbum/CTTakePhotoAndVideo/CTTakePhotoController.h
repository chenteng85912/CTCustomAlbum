//
//  LQTakePhotoController.h
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/6/25.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import "CTTakePhotoButtomView.h"

typedef void (^CTTakePhotoBlock)(UIImage *takeImage,NSString *videoLocalPath);

@interface CTTakePhotoController : UIViewController

/**
  自定义拍照模块 所有需要拍照或录像的地方都调用该模块

 @param takePhotoModel 拍摄模式
 @param isCutImage 是否需要切图
 @param block 回调图片
 */
+ (void)showTakePhotoOrVideo:(CTTakePhotoButtomViewModel)takePhotoModel
                  isCutImage:(BOOL)isCutImage
                       block:(CTTakePhotoBlock)block;

@end
