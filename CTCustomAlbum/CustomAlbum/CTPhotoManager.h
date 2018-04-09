//
//  PhotosDataCenter.h
//
//  Created by chenteng on 2017/12/4.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTPhotosConfig.h"
#import "CTCollectionModel.h"

@protocol CTSendPhotosProtocol <NSObject>

@optional
//传出图片数组
- (void)sendImageArray:(NSArray <UIImage *> *)imgArray;

@end

@interface CTPhotoManager : NSObject

/**
 获取相册分组
 
 @param groupsBlock 返回相册分组
 */
+ (void)fetchDefaultAllPhotosGroup:(void (^)(NSArray<PHAssetCollection *> * groupArray))groupsBlock;

/**
 发送图片

 @param collectionModel 某个相册的数据
 @param imagesBlock 回调 dismiss
 */
+ (void)sendImageData:(CTCollectionModel *)collectionModel
          imagesBlock:(CTCustomImagesBLock)imagesBlock;
//获取代理
+ (id <CTSendPhotosProtocol>)delegate;

//设置代理
+ (void)setDelegate:(id <CTSendPhotosProtocol>)delegate;

@end
