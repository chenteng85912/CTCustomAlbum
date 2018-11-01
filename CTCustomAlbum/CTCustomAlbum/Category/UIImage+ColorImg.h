//
//  UIImage+ColorImg.h
//  CTCustomAlbum
//
//  Created by 陈腾 on 2018/4/11.
//  Copyright © 2018年 陈腾. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ColorImg)


/**
 根据颜色生成图片

 @param color 颜色
 @param size 图片尺寸
 @return 图片
 */
+ (instancetype)imageFromColor:(UIColor *)color size:(CGSize)size;

//获取视频截图
+ (UIImage *)getVideoShotImage:(NSURL *)videoUrl;
+ (UIImage *)vectorImageWithName:(NSString *)name size:(CGSize)size stretch:(BOOL)stretch;

//正常摆正图片方向
- (UIImage *)normalizedImage;

- (UIImage *)rotate:(UIImageOrientation)orient;


@end
