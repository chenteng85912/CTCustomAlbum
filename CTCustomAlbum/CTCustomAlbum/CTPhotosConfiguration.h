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

//照片类型
+ (NSArray <NSNumber *> *)groupNamesConfig;

//输出照片压缩比 默认0.6
+ (CGFloat)outputPhotosScale;

//最大数量 默认9
+ (NSInteger)maxNum;

/**
 设置图片压缩比 最大选择数量

 @param scale 压缩比
 @param maxNum 最大选择数量
 */
+ (void)setPhotosScale:(CGFloat)scale maxNum:(NSInteger)maxNum;

@end
