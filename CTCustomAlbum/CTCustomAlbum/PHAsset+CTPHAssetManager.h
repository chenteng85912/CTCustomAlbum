//
//  PHAsset+CTPHAssetManager.h
//
//  Created by chenteng on 2017/12/14.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import <Photos/Photos.h>

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
 
 @param completeBlock 返回缩略图
 */
- (void)fetchPreviewImageComplete:(nonnull void (^)(UIImage * _Nullable thumbImg,NSDictionary * _Nullable info))completeBlock;
/**
 获取原图
 
 @param completeBlock 返回原图
 */
- (void)fetchOriginImageComplete:(void (^_Nullable)( UIImage * _Nonnull originImg))completeBlock;

/**
 获取原始图片的大小
 
 @ 返回图片大小
 */
- (NSNumber * _Nullable)getImageSize;

@end
