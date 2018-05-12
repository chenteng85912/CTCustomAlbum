//
//  AlbumModel.h
//
//  Created by chenteng on 2017/12/4.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTPhotosConfig.h"
#import "PHAsset+CTPHAssetManager.h"

@interface CTPHAssetModel : NSObject

/**
 图片系统对象
 */
@property (nonatomic,strong) PHAsset *asset;

/**
 图片名称
 */
@property (nonatomic,strong) NSString *photoName;

/**
 是否被选中
 */
@property (nonatomic,assign) BOOL selected;//是否选中

/**
 是否包含原图
 */
@property (nonatomic,assign) BOOL originImg;

/**
 是否正在下载
 */
@property (nonatomic,assign) BOOL downloading;

+ (instancetype)initWithAsset:(PHAsset *)asset;

/**
 从iCloud下载图片

 @param block 下载成功回调
 */
- (void)downLoadImageFromiCloud:(dispatch_block_t)block;

@end
