//
//  PHAsset+CTPHAssetManager.h
//
//  Created by chenteng on 2017/12/14.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface PHAsset (CTPHAssetManager)

/**
 检测照片是否在本地
 
 @return 返回检测结果
 */
- (BOOL)checkLocalAsset;

/**
 根据size获取缩略图
 
 @param size 希望显示的尺寸大小
 @param completeBlock 返回缩略图
 */
- (void)fetchThumbImageWithSize:(CGSize)size complete:(nonnull void (^)(UIImage * _Nullable img,NSDictionary * _Nullable info))completeBlock;

/**
 根据size获取缩略图
 
  @param progressHandler 下载进度
  @param completeBlock 返回缩略图
 */
- (void)fetchPreviewImageComplete:(PHAssetImageProgressHandler)progressHandler
                   completeHandle:(nonnull void (^)(UIImage * _Nullable thumbImg,NSDictionary * _Nullable info))completeBlock;

- (void)fetchVideoComplete:(PHAssetImageProgressHandler)progressHandler
            completeHandle:(nonnull void (^)(AVURLAsset * asset))completeBlock;
/**
 获取原图
 
 @param completeBlock 返回原图
 */
- (void)fetchOriginImageComplete:(void (^_Nullable)( UIImage * _Nonnull originImg))completeBlock;

/**
 同步获取原图
 
 @return 返回原图数据
 */
- (NSData *_Nullable)fetchOriginImagData;

/**
 获取原始图片的大小
 
 @ 返回图片大小
 */
- (NSNumber * _Nullable)getImageSize;

NS_ASSUME_NONNULL_END

@end
