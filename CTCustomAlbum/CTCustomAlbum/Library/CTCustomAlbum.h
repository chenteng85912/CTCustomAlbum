//
//  CTCustomAlbum.h
//  TYKYLibraryDemo
//
//  Created by 陈腾 on 2018/4/4.
//  Copyright © 2018年 CHENTENG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTPhotoManager.h"
#import "CTTakePhotoController.h"
#import "CTPhotosConfiguration.h"

@interface CTCustomAlbum : NSObject

/**
 初始化相册导航栏控制器
 
 @param delegate 遵循CTSendPhotosProtocol协议的对象
 */
+ (void)showCustomAlbumWithDelegate:(id <CTSendPhotosProtocol>)delegate;

/**
 初始化相册导航栏控制器
 
 @param block 选择图片回调

 */
+ (void)showCustomAlbumWithBlock:(CTCustomMediasBLock)block;

@end
