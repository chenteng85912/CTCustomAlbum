//
//  CTCustomAlbum.h
//  TYKYLibraryDemo
//
//  Created by 陈腾 on 2018/4/4.
//  Copyright © 2018年 CHENTENG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTPhotoManager.h"

@interface CTCustomAlbum : NSObject

/**
 初始化相册导航栏控制器
 
 @param delegate 遵循CTSendPhotosProtocol协议的对象
 */
+ (void)showCustomAlbumWithDelegate:(id <CTSendPhotosProtocol>)delegate;


/**
 初始化相册导航栏控制器
 
 @param delegate 遵循CTSendPhotosProtocol协议的对象
 @param scale 图片压缩比例 默认为0.6
 @param maxNum 最大选择数量 默认为9
 */
+ (void)showCustomAlbumWithDelegate:(id <CTSendPhotosProtocol>)delegate
                         photoScale:(CGFloat)scale
                             maxNum:(NSInteger)maxNum;


/**
 初始化相册导航栏控制器
 
 @param block 选择图片回调

 */
+ (void)showCustomAlbumWithBlock:(CTCustomImagesBLock)block;


/**
 初始化相册导航栏控制器
 
 @param scale 图片压缩比例 默认为0.6
 @param maxNum 最大选择数量 默认为9
 @param block 选择图片回调
 */
+ (void)showCustomAlbumWithPhotoScale:(CGFloat)scale
                               maxNum:(NSInteger)maxNum
                                block:(CTCustomImagesBLock)block;
@end
