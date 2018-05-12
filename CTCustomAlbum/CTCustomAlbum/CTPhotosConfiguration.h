//
//  CTPhotosConfiguration.h
//
//  Created by chenteng on 2017/12/12.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Device_height   [[UIScreen mainScreen] bounds].size.height
#define Device_width    [[UIScreen mainScreen] bounds].size.width


@interface CTPhotosConfiguration : NSObject

/**
 显示的照片类型

 @return 返回照片类型数组
 */
+ (NSArray <NSNumber *> *)groupNamesConfig;

/**
 照片压缩比 默认0.6

 @return 照片压缩比
 */
+ (CGFloat)outputPhotosScale;

/**
 最大数量 默认9

 @return 最大数量
 */
+ (NSInteger)maxNum;

/**
 设置图片压缩比 最大选择数量

 @param scale 压缩比
 @param maxNum 最大选择数量
 */
+ (void)setPhotosScale:(CGFloat)scale maxNum:(NSInteger)maxNum;

@end
