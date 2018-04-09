//
//  CTPhotosNavigationViewController.h
//
//  Created by chenteng on 2017/12/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "CTPhotosConfig.h"
#import "CTPhotoManager.h"

@interface CTPhotosNavigationViewController : UINavigationController

/**
 初始化相册导航栏控制器

 @param delegate 遵循CTSendPhotosProtocol协议的对象
 @return 返回实例对象
 */
+ (instancetype)initWithDelegate:(id <CTSendPhotosProtocol>)delegate;


/**
  初始化相册导航栏控制器

 @param delegate 遵循CTSendPhotosProtocol协议的对象
 @param scale 图片压缩比例 默认为0.6
 @param maxNum 最大选择数量 默认为9
 @return 返回实例对象
 */
+ (instancetype)initWithDelegate:(id <CTSendPhotosProtocol>)delegate
                      photoScale:(CGFloat)scale
                          maxNum:(NSInteger)maxNum;


/**
 初始化相册导航栏控制器

 @param block 选择图片回调
 @return 返回实例化对象
 */
+ (instancetype)initWithBlock:(CTCustomImagesBLock)block;


/**
  初始化相册导航栏控制器

 @param block 选择图片回调
 @param scale 图片压缩比例 默认为0.6
 @param maxNum 最大选择数量 默认为9
 @return 返回实例对象
 */
+ (instancetype)initWithBlock:(CTCustomImagesBLock)block
                   photoScale:(CGFloat)scale
                       maxNum:(NSInteger)maxNum;
@end
