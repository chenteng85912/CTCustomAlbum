//
//  PHAssetCollection+CTAssetCollectionManager.h
//
//  Created by chenteng on 2017/12/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHAssetCollection (CTAssetCollectionManager)

/**
 获取相册基本信息
 
 @param size 获取图片的大小
 @param completeBlock 相册名称，相册照片数量，最新照片缩略图
 */
- (void)fetchCollectionInfoWithSize:(CGSize)size
                           complete:(nonnull void (^)(NSString * _Nonnull title, NSUInteger assetCount, UIImage * _Nullable image))completeBlock;


/**
 获取某个相册的所有照片

 @return 返回照片集合
 */
- (PHFetchResult *_Nullable)fetchCollectionAssets;

@end
