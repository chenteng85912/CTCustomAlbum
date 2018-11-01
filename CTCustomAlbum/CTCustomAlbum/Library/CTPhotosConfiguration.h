//
//  CTPhotosConfiguration.h
//
//  Created by chenteng on 2017/12/12.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import <UIKit/UIKit.h>

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
 是否显示视频

 @return 是否显示视频
 */
+ (BOOL)showVideo;

/**
 是否选择图片作为头像

 @return 是否打开该模式
 */
+ (BOOL)chooseHead;

/**
 是否打开单选模式

 @return 是否打开单选模式
 */
+ (BOOL)oneChoose;
/**
 设置图片压缩比 最大选择数量

 @param scale 压缩比
 @param maxNum 最大选择数量
 */
+ (void)setPhotosScale:(CGFloat)scale maxNum:(NSInteger)maxNum;

/**
 需要显示视频

 @param showVideo 显示视频
 */
+ (void)setVideoShow:(BOOL)showVideo;

/**
 设置是否选择图片作为头像
 
 @param chooseHead 是否打开该模式
 */
+ (void)setChooseHead:(BOOL)chooseHead;

/**
 是否打开单选模式

 @param single 单选
 */
+ (void)setOneChoose:(BOOL)single;

@end
